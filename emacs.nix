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
    rev = "d93a439846f03dfb2be28d6b5c2e963ef6be0c22";
    hash = "sha256-c9SwLw7SVau/1CObNQyNygf0AOHfxfj6q1T10XNMaRw=";
  };

  version = "29.0.60";

  configureFlags = o.configureFlags ++ [
    "--with-tree-sitter"
  ];

  nativeBuildInputs = o.nativeBuildInputs ++ [
    tree-sitter
  ];

})
