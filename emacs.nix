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
    rev  = "43b81b7ecaf465eef268dd2cd94f00a0c4da87ea";
    hash = "sha256-CDUAE8apvejLrbWk9KdKkJNlt8OXpAsVcLqev97TJLE=";
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
  configureFlags = o.configureFlags or [] ++ ["--disable-gc-mark-trace"];
  postInstall = o.postInstall + ''
    find $out/share/applications -type f -name '*.desktop' -and -not -name emacs.desktop -delete
  '';
})
