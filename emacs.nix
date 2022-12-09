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
    rev = "f1942c298cd05f0a739a0c5fff4fc90dc566ae79";
    hash = "sha256-KfiJQ7QwPH9HaU1VJtJMNCe7phR6kslAsl2jVOBmdDI=";
  };

  version = "30.0.50";

  configureFlags = o.configureFlags ++ [
    "--with-tree-sitter"
  ];

  nativeBuildInputs = o.nativeBuildInputs ++ [
    tree-sitter
  ];

})
