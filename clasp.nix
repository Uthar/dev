{ pkgs, lib, fetchFromGitHub, llvmPackages_14, nix, ...}:


let

  src = fetchFromGitHub {
    owner = "clasp-developers";
    repo = "clasp";
    rev = "ce81d67c5766e69df96dc3aee9f69387565cdc60";
    hash = "sha256-b0ziKTwS11E4Nd0St3JwjoO9aImbLomKUUEipm3of/U=";
  };

  reposDirs = [
    "dependencies"
    "src/lisp/kernel/contrib"
    "src/lisp/modules/asdf"
    "src/mps"
    "src/bdwgc"
    "src/libatomic_ops"
  ];

  reposTarball = llvmPackages_14.stdenv.mkDerivation {
    pname = "clasp-repos";
    version = "tarball";
    inherit src;
    patches = [ ./patches/clasp-pin-repos-commits.patch ];
    nativeBuildInputs = with pkgs; [
      sbcl
      git
      cacert
    ];
    buildPhase = ''
      export SOURCE_DATE_EPOCH=1
      export ASDF_OUTPUT_TRANSLATIONS=$(pwd):$(pwd)/__fasls
      sbcl --script koga --help
      for x in {${lib.concatStringsSep "," reposDirs}}; do
        find $x -type d -name .git -exec rm -rvf {} \; || true
      done
    '';
    installPhase = ''
      tar --owner=0 --group=0 --numeric-owner --format=gnu \
        --sort=name --mtime="@$SOURCE_DATE_EPOCH" \
        -czf $out ${lib.concatStringsSep " " reposDirs}
    '';
    outputHashMode = "flat";
    outputHashAlgo = "sha256";
    outputHash = "sha256-011140qCAtHJp2agtlQ4oZ0SQGmOLhVbNdfAQ3Naoo8=";
  };

in llvmPackages_14.stdenv.mkDerivation { 
  pname = "clasp";
  version = "2.0.0-tip";  
  inherit src;
  nativeBuildInputs = (with pkgs; [
    sbcl
    git
    pkg-config
    fmt
    gmpxx
    libelf
    boost
    libunwind
    ninja
  ]) ++ (with llvmPackages_14; [
    llvm
    libclang
  ]) ++ [
    nix
  ];
  configurePhase = ''
    export SOURCE_DATE_EPOCH=1
    export ASDF_OUTPUT_TRANSLATIONS=$(pwd):$(pwd)/__fasls
    tar xf ${reposTarball}
    sbcl --script koga \
      --skip-sync \
      --cc=$NIX_CC/bin/cc \
      --cxx=$NIX_CC/bin/c++ \
      --reproducible-build \
      --package-path=/ \
      --bin-path=$out/bin \
      --lib-path=$out/lib \
      --share-path=$out/share
  '';
  buildPhase = ''
    ninja -C build
  '';
  installPhase = ''
    ninja -C build install    
  '';
}
