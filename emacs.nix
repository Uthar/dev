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
    rev = "f1ce49d148b334a8fb5302c4dd596aceffbb6b57";
    hash = "sha256-YgUSY3Fi2lXsxO0gHKwuzuEshv+eCkckGlAbQjh9b4M=";
  };

  version = "30.0.50";

  configureFlags = o.configureFlags ++ [
    "--with-tree-sitter"
  ];

  nativeBuildInputs = o.nativeBuildInputs ++ [
    tree-sitter
  ];

})
