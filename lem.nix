{ stdenv
, lib
, runCommand
, fetchFromGitHub
, makeWrapper
, which
, git
, cacert
, hexdump
, sbcl
, SDL2
, SDL2_ttf
, SDL2_image
, libffi
, openssl
, ...
}:

let

  dot-qlot = stdenv.mkDerivation {
    pname = "lem-dot-qlot";
    version = "2.2.0-trunk";
    src = fetchFromGitHub {
      owner = "lem-project";
      repo = "lem";
      rev = "ca31053a7e45a608917f7bb2ccff426f9b4b0c94";
      hash = "sha256-KlnBzP4E3wuG4xxnI54Yr2QPHJaCXHodOVccCVpWudI=";
    };
    buildInputs = [ hexdump which cacert git sbcl.pkgs.qlot-cli sbcl ];
    postConfigure = ''
      export ASDF_OUTPUT_TRANSLATIONS="/:$(pwd)/.fasl"
    '';
    buildPhase = ''
      qlot install
    '';
    installPhase = ''
      rm .qlot/qlot.conf
      rm .qlot/source-registry.conf
      rm .qlot/quicklisp/*.fasl
      rm .qlot/dists/*/preference.txt
      cp -r .qlot $out
    '';
    dontFixup = true;
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-3FSBcpxWhnk0LcqozGpR+6Tz2o7TlTaWO7tsLDV4JCY=";
  };

  lem-sdl2 = stdenv.mkDerivation {
    pname = "lem-sdl2";
    version = "2.2.0-trunk";
    src = fetchFromGitHub {
      owner = "lem-project";
      repo = "lem";
      rev = "ca31053a7e45a608917f7bb2ccff426f9b4b0c94";
      hash = "sha256-KlnBzP4E3wuG4xxnI54Yr2QPHJaCXHodOVccCVpWudI=";
    };
    nativeBuildInputs = [ which sbcl sbcl.pkgs.qlot-cli makeWrapper ];
    buildInputs = [ libffi openssl ];
    configurePhase = ''
      export ASDF_OUTPUT_TRANSLATIONS="$(pwd):$(pwd)"
      export CL_SOURCE_REGISTRY="$(pwd)//"
      export HOME="$(pwd)"
      cp -r ${dot-qlot} ./.qlot
      chmod u+w -R ./.qlot
    '';
    LD_LIBRARY_PATH = lib.makeLibraryPath [
      SDL2 SDL2_image SDL2_ttf libffi openssl
    ];
    buildPhase = ''
      make sdl2
    '';
    dontFixup = true;
    installPhase = ''
      mkdir -pv $out/bin
      sbcl <<EOF
        (require 'asdf)
        (load ".qlot/setup.lisp")
        (asdf:load-system 'lem-sdl2)
        (sb-ext:save-lisp-and-die "$out/bin/lem" :executable t :toplevel #'lem:main)
      EOF
      test -x $out/bin/lem
      wrapProgram $out/bin/lem --prefix LD_LIBRARY_PATH : $LD_LIBRARY_PATH
    '';
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
