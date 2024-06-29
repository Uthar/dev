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
    rev = "94bcd7964bbb20bc8ff8a91a9656452a97139d60";
    hash = "sha256-Ka6x1Zc8P/yxRWXSVXS0gEBOAZK7L4uF6Uz+CEcubk4=";
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
    withNativeCompilation = true; # Takes too long
  };
  
in emacs.overrideAttrs (o: {
  inherit src;
  version = "30.0.50";
  patches = [];  
  postInstall = o.postInstall + ''
    find $out/share/applications -type f -name '*.desktop' -and -not -name emacs.desktop -delete
  '';
})
