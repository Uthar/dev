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
    rev = "7930fe2f44f50b6a7abf5fbe1218dcc15e85b28d";
    hash = "sha256-pDhC6CuSlO+FnCA9klgk/O++pAUCqTKrzFPgX6HOGJs=";
  };

  siteStart = pkgs.writeText "site-lisp.el" ''
    (setq native-comp-driver-options '(${jitFlags}))
    (setq find-function-C-source-directory "${src}/src")
  '';
    
  emacs = pkgs.emacs.override {
    inherit sqlite;
    inherit siteStart;
    withGTK3 = true;
    withXwidgets = false;
    withSQLite3 = true;
    withTreeSitter = true;
    withNativeCompilation = true;
  };
  
in emacs.overrideAttrs (o: {
  inherit src;
  version = "31.0.50";
  patches = [];  
  postInstall = o.postInstall + ''
    find $out/share/applications -type f -name '*.desktop' -and -not -name emacs.desktop -delete
  '';
})
