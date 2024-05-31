(load (sb-ext:posix-getenv "ASDF"))

(mapc #'asdf:load-system '("alexandria" "bordeaux-threads" "cl-cpus" "com.inuoe.jzon"))

(defpackage clasp
  (:use :cl)
  (:import-from  :uiop)
  (:import-from :cpus)
  (:local-nicknames
   (:a :alexandria)
   (:bt :bordeaux-threads-2)
   (:json :com.inuoe.jzon)))

(in-package clasp)

(defvar *log-lock* (bt:make-lock :name "logging"))

(defun info (&rest args)
  (bt:with-lock-held (*log-lock*)
    (format t "INFO: ~{~A~^ ~}~%" args)))

(defun read-repos-sexp (&optional (path "repos.sexp"))
  "Read the repos.sexp file from a clasp git checkout"
  (with-open-file (stream path)
    (let ((*read-eval* nil))
      (read stream))))

(defun parse-ls-remote (string)
  "Parse the response of git ls-remote"
  (let ((result (list))
        (lines (uiop:split-string string :separator '(#\Newline))))
    (dolist (line lines)
      (destructuring-bind (hash ref)
          (uiop:split-string line)
        (push (list :hash hash :ref ref) result)))
    result))

(defun ls-remote (&key repository branch commit &allow-other-keys)
  "Run git ls-remote"
  (parse-ls-remote
   (uiop:run-program
    ;; Commit is sometimes the tag, not the actual commit
    (list "git" "ls-remote" repository (or branch commit))
    :output '(:string :stripped t))))

(defun get-latest-commit (&rest args &key commit &allow-other-keys)
  "Get the hash of the lastest commit on the branch"
  (let ((refs (apply #'ls-remote args)))
    (cond
      ((= 1 (length refs))
       (getf (first refs) :hash))      
      ((= 0 (length refs))
       ;; Assume commit was valid
       commit)
      (t (error "Cannot determine last commit")))))

(defun pprint-plist (stream plist)
  "Pretty print plist to match how repos.sexp looks like originally"
  (let ((*print-case* :downcase))
    (format stream "(~{(~{~s ~s~^~%  ~})~^~% ~})" plist)))

(defun gen-patch (updated-sexp &optional (original-path "repos.sexp"))
  "Generate a patch from the original repos.sexp to the one with pinned commits"
  (uiop:with-temporary-file (:stream stream :pathname pathname)
    (pprint-plist stream updated-sexp)
    (fresh-line stream)
    (force-output stream)
    (uiop:run-program
     (list "diff"
           "--label" "a/repos.sexp"
           "--label" "b/repos.sexp"
           "-u" original-path (namestring pathname))
     :output :string
     :ignore-error-status t)))

(defun update-commits (entries)
  "Return the repo entries with their commits updated to the latest values"
  (let ((sem (bt:make-semaphore :count (cpus:get-number-of-processors)))
        (push-lock (bt:make-lock))
        (threads (list))
        (all (list)))
    (dolist (entry entries)
      (bt:wait-on-semaphore sem)
      (push (bt:make-thread 
             (lambda ()
               (unwind-protect
                    (let ((updated (update-commit entry)))
                      (bt:with-lock-held (push-lock)
                        (push updated all)))
                 (bt:signal-semaphore sem))))
            threads))
    (dolist (thread threads)
      (bt:join-thread thread))
    all))

(defun update-commit (entry)
  "Return a fresh plist with commit set to the latest commit for its branch"
  (info "working on" (getf entry :repository))
  (let ((commit (apply #'get-latest-commit entry)))
    (if (getf entry :commit)
        ;; Update the existing commit field (creates one line of diff)
        (let ((updated (copy-list entry)))
          (setf (getf updated :commit) commit)
          updated)
        ;; Add commit at previous to last position (this is for nicer diffs)
        (let ((alist (a:plist-alist entry)))
          (a:alist-plist
           (reverse
            (cons (a:lastcar alist)
                  (acons :commit commit (reverse (butlast alist))))))))))

(defun in-original-order (before after)
  ;; Arrange back into the original order - it's random now after being
  ;; processed in parallel (this is again for nicer diffs)
  (let ((sorted (list)))
    (dolist (original before)
      (let ((entry
              (find-if (lambda (entry)
                         (equal (getf entry :name)
                                (getf original :name)))
                       after)))
        (if entry
            (push entry sorted)
            ;; It is probably a skipped one with extension field.
            ;; Let's push it to keep the diff smaller.
            (push original sorted))))
    (reverse sorted)))

(defun random-string (length)
  (let ((string (make-string length)))
    (dotimes (n length)
      (do ((code (random 128) (random 128)))
          ((alphanumericp (code-char code))
           (setf (aref string n) (code-char code)))))
    string))

(defun update-repo-hash (repo)
  (destructuring-bind (&key repository directory commit &allow-other-keys) repo
    (let ((repo-with-hash (make-hash-table :test 'equal))
          (clonedir (merge-pathnames                     
                     (make-pathname :directory `(:relative ,(random-string 15)))
                     (uiop:temporary-directory)))
          (fetchgit-args (make-hash-table :test 'equal)))
      (unwind-protect
           (progn
             (info "cloning" repository)
             (shallow-checkout repository commit clonedir)
             (setf (gethash "directory" repo-with-hash) directory)
             (setf (gethash "url" fetchgit-args) repository)
             (setf (gethash "rev" fetchgit-args)
                   (uiop:run-program
                    (list "git" "-C" (namestring clonedir)
                          "rev-parse" "HEAD")
                    :output '(:string :stripped t)))
             (delete-dot-git clonedir)
             (setf (gethash "hash" fetchgit-args)
                   (uiop:run-program
                    (list "nix" "hash" "path" (namestring clonedir))
                    :output '(:string :stripped t)))
             (setf (gethash "fetchgitArgs" repo-with-hash) fetchgit-args)
             repo-with-hash)
        (uiop:delete-directory-tree clonedir :validate (constantly t))))))

(defun shallow-checkout (repository revision directory)
  (uiop:run-program
   (list "git" "init" (namestring directory)))
  (uiop:run-program
   (list "git" "-C" (namestring directory)
         "fetch" "--depth" "1" repository revision))
  (uiop:run-program
   (list "git" "-C" (namestring directory) "checkout" "FETCH_HEAD")))

(defun delete-dot-git (checkout)
  (uiop:delete-directory-tree
   (merge-pathnames (make-pathname :directory '(:relative ".git")) checkout)
   :validate (constantly t)))

(defun main ()
  (unless (string= (a:lastcar (pathname-directory (uiop:getcwd))) "dev")
    (error "Must run from 'dev' repo"))
  (info "Checking out latest clasp")
  (shallow-checkout
   "https://github.com/clasp-developers/clasp.git"
   "main"
   (make-pathname :directory '(:relative "clasp-checkout")))
  (let* ((original-path "clasp-checkout/repos.sexp")
         (all (read-repos-sexp original-path))
         ;; For now I only want to build the base clasp without extensions
         (build (remove-if (lambda (entry) 
                               (getf entry :extension))
                             all))
         (updated (update-commits build))
         (final (in-original-order all updated))
         (patch (gen-patch final original-path)))
    (info "updating pins")
    (with-open-file (stream "patches/clasp-pin-repos-commits.patch"
                            :direction :output
                            :if-exists :supersede)
      (write-string patch stream))
    (info "updating dependency hashes")
    (with-open-file (stream "clasp.json"
                            :direction :output
                            :if-exists :supersede)
      (let ((config (make-hash-table :test 'equal))
            (src (make-hash-table :test 'equal))
            (repos (make-array (length updated)
                               :adjustable t
                               :fill-pointer 0))
            (version (uiop:read-file-form "clasp-checkout/version.sexp")))
        (setf (gethash "owner" src) "clasp-developers")
        (setf (gethash "repo" src) "clasp")
        (setf (gethash "rev" src)
              (uiop:run-program
               (list "git" "-C" "clasp-checkout"
                     "rev-parse" "HEAD")
               :output '(:string :stripped t)))
        (delete-dot-git (make-pathname :directory '(:relative "clasp-checkout")))
        (setf (gethash "hash" src)
              (uiop:run-program
               (list "nix" "hash" "path" "clasp-checkout")
               :output '(:string :stripped t)))
        (setf (gethash "src" config) src)
        (setf (gethash "version" config) (getf version :version))
        (setf (gethash "repos" config)
              (stable-sort (map 'vector #'update-repo-hash updated)
                           #'string<
                           :key (lambda (r) (gethash "directory" r))))
        (file-position stream 0)
        (write-string (json:stringify config :pretty t) stream)
        (fresh-line stream)))
    (info "done")
    (values)))

(unwind-protect
     (main)
  (ignore-errors (delete-file "repos.sexp"))
  (ignore-errors
   (uiop:delete-directory-tree (make-pathname :directory '(:relative "clasp-checkout")) :validate (constantly t))))
