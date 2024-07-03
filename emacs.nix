{ pkgs, lib, stdenv, fetchFromSavannah, sqlite, tree-sitter, libgccjit, ... }:

let

  jitFlags = lib.concatMapStringsSep " " (x: "\"-B${x}\"") [
    "${lib.getLib libgccjit}/lib"
    "${lib.getLib libgccjit}/lib/gcc"
    "${lib.getLib stdenv.cc.libc}/lib"
    "${lib.getLib stdenv.cc.cc.libgcc}/lib"
    "${lib.getBin stdenv.cc.cc}/bin"
    "${lib.getBin stdenv.cc.bintools}/bin"
    "${lib.getBin stdenv.cc.bintools.bintools}/bin"
  ];
  
  # Recent tip of trunk
  # https://git.savannah.gnu.org/cgit/emacs.git/log/
  src = fetchFromSavannah {
    repo = "emacs";
    rev = "f7725d85f3132fb684032438f81defcb481892b7";
    hash = "sha256-fDSlEf1FpjOu5t1lzKFg6Fkzy5mztdZKtt8SqmPdH2k=";
  };

  siteStart = pkgs.writeText "site-lisp.el" ''
    (setq native-comp-driver-options '(${jitFlags}))
    (setq find-function-C-source-directory "${src}/src")
  '';
    
  emacs = pkgs.emacs.override {
    inherit sqlite;
    inherit siteStart;
    withGTK2 = true;
    withSQLite3 = true;
    withTreeSitter = true;
    withNativeCompilation = false; # Takes too long
  };
  
in emacs.overrideAttrs (o: {
  inherit src;
  version = "31.0.50";
  patches = [];  
  postInstall = o.postInstall + ''
    find $out/share/applications -type f -name '*.desktop' -and -not -name emacs.desktop -delete
  '';
})
