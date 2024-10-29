{ stdenv
, lib
, runCommand
, fetchFromGitHub
, makeWrapper
, sbcl
, SDL2
, SDL2_ttf
, SDL2_image
, ...
}:

let

  src = fetchFromGitHub {
    owner = "lem-project";
    repo = "lem";
    rev = "742c607e2c555c2c5f7c22e2689aa58154e08489";
    hash = "sha256-ENVx2OhRE4fqWo79gb0vFroA0EQNGZ+vipJ9H6XC6Fw=";
  };

  sbcl' = sbcl.withOverrides (self: super: {
    
    micros = sbcl.buildASDFSystem {
      pname = "micros";
      version = "trunk";
      src = fetchFromGitHub {
        owner = "lem-project";
        repo = "micros";
        rev = "af94fe5d6688f67a092f604765fb706ebae44e99";
        hash = "sha256-XmKTMJy+8xt2ImlGXSyXdXsLOUFFB0W45ROD4OIvyPY=";
      };
    };
    
    lem-mailbox = sbcl.buildASDFSystem {
      pname = "lem-mailbox";
      version = "trunk";
      src = fetchFromGitHub {
        owner = "lem-project";
        repo = "lem-mailbox";
        rev = "12d629541da440fadf771b0225a051ae65fa342a";
        hash = "sha256-hb6GSWA7vUuvSSPSmfZ80aBuvSVyg74qveoCPRP2CeI=";
      };
      lispLibs = with self; [
        bordeaux-threads
        bt-semaphore
        queues
        queues_dot_simple-cqueue
      ];
    };    
    
    async-process = sbcl.buildASDFSystem {
      pname = "async-process";
      version = "trunk";
      src = fetchFromGitHub {
        owner = "lem-project";
        repo = "async-process";
        rev = "3b16b91d417530dac03559980fb5703206e20c55";
        hash = "sha256-5J3+gc7r/LhrKPXeHGwfghKaXB+AoaXhjS8b4lida3o=";
      };
      lispLibs = with self; [
        cffi
      ];
    };
    
    rove = sbcl.buildASDFSystem {
      pname = "rove";
      version = "trunk";
      src = fetchFromGitHub {
        owner = "fukamachi";
        repo = "rove";
        rev = "cacea7331c10fe9d8398d104b2dfd579bf7ea353";
        hash = "sha256-BTRahe/vQI1PET0KzUF/ZPitM0omuMXbz2jS7FArpbM=";
      };
      lispLibs = with self; [
        cl-ppcre
        dissect
        bordeaux-threads
        trivial-gray-streams
      ];
    };
    
    sdl2 = sbcl.buildASDFSystem {
      pname = "sdl2";
      version = "trunk";
      src = fetchFromGitHub {
        owner = "lem-project";
        repo = "cl-sdl2";
        rev = "24dd7f238f99065b0ae35266b71cce7783e89fa7";
        hash = "sha256-ewMDcM3byCIprCvluEPgHD4hLv3tnUV8fjqOkVrFZSE=";
      };
      lispLibs = with self; [
        alexandria
        cl-autowrap
        cl-plus-c
        cl-ppcre
        trivial-channels
        trivial-features
      ] ++ (lib.optional stdenv.isDarwin self.cl-glut);
      nativeLibs = [
        SDL2
      ];
    };
    
    sdl2-ttf = sbcl.buildASDFSystem {
      pname = "sdl2-ttf";
      version = "trunk";
      src = fetchFromGitHub {
        owner = "lem-project";
        repo = "cl-sdl2-ttf";
        rev = "f43344efe89cf9ce509e6ce4f7303ebb2ff14434";
        hash = "sha256-1b0SMUipVaLq7WdDgaR9ZZhs0/c1/wyRkULsrBfTvEU=";
      };
      lispLibs = with self; [
        alexandria
        defpackage-plus
        cl-autowrap
        sdl2
        cffi-libffi
        trivial-garbage
      ];
      nativeLibs = [
        (SDL2_ttf.overrideAttrs (a: {
          configureFlags = a.configureFlags ++ [ "--disable-freetype-builtin" ];
        }))
      ];
    };
    
    sdl2-image = sbcl.buildASDFSystem {
      pname = "sdl2-image";
      version = "trunk";
      src = fetchFromGitHub {
        owner = "lem-project";
        repo = "cl-sdl2-image";
        rev = "8734b0e24de9ca390c9f763d9d7cd501546d17d4";
        hash = "sha256-TNcPOBKlB5eTlHtDAW/hpkWDMZZ/sFCHnm7dapMm5lg=";
      };
      lispLibs = with self; [
        alexandria
        defpackage-plus
        cl-autowrap
        sdl2
      ];
      nativeLibs = [
        SDL2_image
      ];
    };
    
    jsonrpc = sbcl.buildASDFSystem {
      pname = "jsonrpc";
      version = "trunk";
      src = fetchFromGitHub {
        owner = "cxxxr";
        repo = "jsonrpc";
        rev = "2af1e0fad429ee8c706b86c4a853248cdd1be933";
        hash = "sha256-N3j9eFS+jj390cjYltRCq9HyyTNUIukAJEzTqR0opU0=";
      };
      systems = [
        "jsonrpc"
        "jsonrpc/transport/stdio"
        "jsonrpc/transport/tcp"
      ];
      lispLibs = with self; [
        yason
        usocket
        bordeaux-threads
        alexandria
        dissect
        event-emitter
        chanl
        vom
        cl-ppcre
        dexador
        clack
        clack-handler-hunchentoot
        lack-request
        babel
        http-body
        cl_plus_ssl
        quri
        fast-io
        trivial-utf-8
        trivial-timeout
      ];
    };

    lem-full = sbcl.buildASDFSystem {
      pname = "lem-full";
      version = "2.2.0-trunk";
      inherit src;
      nativeCheckInputs = [ sbcl ];
      doCheck = false;
      checkPhase = ''
        sbcl <<EOF
          (load "$asdfFasl/asdf.$faslExt")
          (asdf:load-system 'lem-tests)
          (rove:run "lem-tests")
        EOF
      '';
      lispLibs = with self; [
        iterate
        closer-mop
        trivia
        alexandria
        trivial-gray-streams
        trivial-types
        cl-ppcre
        micros
        inquisitor
        babel
        bordeaux-threads
        yason
        log4cl
        split-sequence
        str
        dexador
        lem-mailbox
        async-process
        usocket
        cl-change-case
        jsonrpc
        trivia_dot_level2
        quri
        cl-package-locks
        esrap
        parse-number
        swank
        _3bmd
        _3bmd-ext-code-blocks
        lisp-preprocessor
        trivial-ws
        trivial-open-browser
        iconv
        cl-base16
        # for tests
        rove
        trivial-package-local-nicknames
        cl-ansi-text
      ];
      systems = [
        "lem"
        "lem-color-preview"
        "lem-encodings-table"
        "lem-encodings"
        "lem-lisp-syntax"
        "lem-process"
        "lem-lsp-base"
        "lem-language-server"
        "lem-language-client"
        "lem/extensions"
        "lem-welcome"
        "lem-lsp-mode"
        "lem-vi-mode"
        "lem-lisp-mode"
        "lem-go-mode"
        "lem-swift-mode"
        "lem-c-mode"
        "lem-xml-mode"
        "lem-html-mode"
        "lem-python-mode"
        "lem-posix-shell-mode"
        "lem-js-mode"
        "lem-typescript-mode"
        "lem-json-mode"
        "lem-css-mode"
        "lem-rust-mode"
        "lem-paredit-mode"
        "lem-nim-mode"
        "lem-scheme-mode"
        "lem-patch-mode"
        "lem-yaml-mode"
        "lem-review-mode"
        "lem-asciidoc-mode"
        "lem-dart-mode"
        "lem-scala-mode"
        "lem-dot-mode"
        "lem-java-mode"
        "lem-haskell-mode"
        "lem-ocaml-mode"
        "lem-asm-mode"
        "lem-makefile-mode"
        "lem-shell-mode"
        "lem-sql-mode"
        "lem-base16-themes"
        "lem-elixir-mode"
        "lem-ruby-mode"
        "lem-erlang-mode"
        "lem-documentation-mode"
        "lem-elisp-mode"
        "lem-terraform-mode"
        "lem-markdown-mode"
        "lem-color-preview"
        "lem-lua-mode"
        "lem-terminal"
        "lem-legit"
        "lem-dashboard"
        "lem-copilot"
      ];
    };
  });

  lem-sdl2 = sbcl'.buildASDFSystem {
    pname = "lem-sdl2";
    version = "2.2.0-trunk";
    inherit src;
    buildInputs = [ sbcl' makeWrapper ];
    lispLibs = with sbcl'.pkgs; [
      sdl2
      sdl2-ttf
      sdl2-image
      lem-full
      trivial-main-thread
    ];
    installPhase = ''
      mkdir -pv $out/bin
      sbcl <<EOF
        (load "$asdfFasl/asdf.$faslExt")
        (asdf:load-system 'lem-sdl2)
        (sb-ext:save-lisp-and-die "$out/bin/lem" :executable t :toplevel #'lem:main)
      EOF
      test -x $out/bin/lem
      wrapProgram $out/bin/lem --prefix LD_LIBRARY_PATH : $LD_LIBRARY_PATH
    '';
    passthru.tests = {
      freetype-png = runCommand "test" {} ''
        ${sbcl'.withPackages(p:[p.sdl2-ttf])}/bin/sbcl --script <<EOF
          (load (sb-ext:posix-getenv "ASDF"))
          (asdf:load-system 'sdl2-ttf)
          (sdl2-ttf:init)
          (let* ((path #P"${lem-sdl2.src}/frontends/sdl2/resources/fonts/NotoColorEmoji.ttf")
                 (font (sdl2-ttf:open-font path 10)))
            (sdl2-ttf:render-utf8-blended font "🔒" 12 34 56 0))
          (with-open-file (out "$out" :direction :output)
            (format out "ok~%"))
        EOF
      '';
    };
    passthru.lem = sbcl'.pkgs.lem-full;
    meta = {
      homepage = "https://lem-project.github.io";
      description = "Common Lisp editor/IDE with high expansibility.";
      longDescription = ''
      Lem is an editor/IDE well-tuned for Common Lisp development.
      It is designed to be lightweight and fast, while still providing a
      rich set of features for Common Lisp development. Lem supports other
      programming languages thanks to its built-in LSP client. You can
      choose between an Emacs and a Vim mode.
      '';
      license = [ lib.licenses.mit ];
      platforms = lib.platforms.all;
      mainProgram = "lem";
    };
  };

in lem-sdl2
