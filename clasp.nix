{ pkgs, lib, fetchFromGitHub, llvmPackages_15, ...}:


let

  src = fetchFromGitHub
    (builtins.fromJSON (builtins.readFile ./clasp-src.json));

  reposDirs = import ./repos-dirs.nix;

  reposTarball = llvmPackages_15.stdenv.mkDerivation {
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
    outputHash = "sha256-6uyMMrvfHyz/RJDzlpVUl8yvCzxkBtf6gsivvOa5iA8=";
  };

in llvmPackages_15.stdenv.mkDerivation { 
  pname = "clasp";
  version = "2.5.0-tip";
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
  ]) ++ (with llvmPackages_15; [
    llvm
    libclang
  ]);
  configurePhase = ''
    export SOURCE_DATE_EPOCH=1
    export ASDF_OUTPUT_TRANSLATIONS=$(pwd):$(pwd)/__fasls
    tar xf ${reposTarball}
    sbcl --script koga \
      --skip-sync \
      --build-mode=bytecode-faso \
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
