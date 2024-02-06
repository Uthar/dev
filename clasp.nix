{ pkgs, lib, fetchFromGitHub, llvmPackages_15, ...}:


let

  config = builtins.fromJSON (builtins.readFile ./clasp.json);

  src = fetchFromGitHub config.src;

  repos = map
    (r: r // { repo = pkgs.fetchgit (r.fetchgitArgs // { fetchSubmodules = false; }); })
    config.repos;

in llvmPackages_15.stdenv.mkDerivation { 
  pname = "clasp";
  version = config.version;
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
    ${lib.concatMapStringsSep "\n" (r: "mkdir -p  ${r.directory}") repos}
    ${lib.concatMapStringsSep "\n" (r: "cp -Tr ${r.repo} ${r.directory}") repos}
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
