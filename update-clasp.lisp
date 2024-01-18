(load "~/quicklisp/setup.lisp")

(ql:quickload '("alexandria" "bordeaux-threads" "cl-cpus"))

(defpackage clasp
  (:use :cl)
  (:import-from  :uiop)
  (:import-from :cpus)
  (:local-nicknames
   (:a :alexandria)
   (:bt :bordeaux-threads-2)))

(in-package clasp)

(defvar *log-lock* (bt:make-lock :name "logging"))

(defun info (&rest args)
  (bt:with-lock-held (*log-lock*)
    (format t "INFO: ~{~A~^ ~}~%" args)))

(defun read-repos-sexp (&optional (path "repos.sexp"))
  "Read the repos.sexp file from a clasp git checkout"
  (with-open-file (stream path)
    (read stream)))

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

(defun main ()
  (unless (string= (a:lastcar (pathname-directory (uiop:getcwd))) "dev")
    (error "Must run from 'dev' repo"))
  (info "updating source hash")
  (uiop:run-program
   (list "nix-prefetch-github"
         "clasp-developers"
         "clasp")
   :output "clasp-src.json")
  (info "downloading latest repos.sexp")
  (let ((tip (get-latest-commit
              :repository "https://github.com/clasp-developers/clasp"
              :branch "main"))
        (url "https://raw.githubusercontent.com/clasp-developers/clasp/~a/repos.sexp"))
    (uiop:run-program
     (list "curl" "-LO" (format nil url tip))))
  (let* ((original-path "repos.sexp")
         (all (read-repos-sexp original-path))
         ;; For now I only want to build the base clasp without extensions
         (build (remove-if (lambda (entry) 
                               (getf entry :extension))
                             all))
         (dirs (mapcar (lambda (entry) (getf entry :directory)) build))
         (updated (update-commits build))
         (final (in-original-order all updated))
         (patch (gen-patch final original-path)))
    (info "updating dirs")
    (with-open-file (stream "repos-dirs.nix"
                            :direction :output
                            :if-exists :supersede)
      (format stream "[~{~s~^~% ~}]~%" dirs))
    (info "updating pins")
    (with-open-file (stream "patches/clasp-pin-repos-commits.patch"
                            :direction :output
                            :if-exists :supersede)
      (write-string patch stream))
    (info "done")
    (values)))

(unwind-protect
     (main)
  (ignore-errors (delete-file "repos.sexp")))
