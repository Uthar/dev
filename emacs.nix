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
    rev = "ad3ec429a12fb8caa460de5911145d1d3c46d626";
    hash = "sha256-vM4p1Zbdxo4qTkdfoN5HVz/Z+xgkm6cRobM83XDbwNo=";
  };

  version = "30.0.50";

  configureFlags = o.configureFlags ++ [
    "--with-tree-sitter"
  ];

  nativeBuildInputs = o.nativeBuildInputs ++ [
    tree-sitter
  ];

})
