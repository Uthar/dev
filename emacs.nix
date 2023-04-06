{ pkgs, fetchFromSavannah, sqlite, tree-sitter, ... }:

let

  emacs = pkgs.emacs.override {
    inherit sqlite;
    withGTK2 = true;
    withSQLite3 = true;
    nativeComp = false; # Takes too long
  };

in emacs.overrideAttrs (o: {

  # Recent tip of trunk
  src = fetchFromSavannah {
    repo = "emacs";
    rev = "5ae0c16732450603efc1a0c900e5f2721a0f620b";
    hash = "sha256-msG2dz7f3x6hxDonstkg2xa4E8YFjSc0+VRxji1lop0=";
  };

  version = "30.0.50";

  configureFlags = o.configureFlags ++ [
    "--with-tree-sitter"
  ];

  nativeBuildInputs = o.nativeBuildInputs ++ [
    tree-sitter
  ];

})
