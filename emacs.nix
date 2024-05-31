{ pkgs, fetchFromSavannah, sqlite, tree-sitter, ... }:

let

  emacs = pkgs.emacs.override {
    inherit sqlite;
    withGTK2 = true;
    withSQLite3 = true;
    withTreeSitter = true;
    withNativeCompilation = false; # Takes too long
  };

in emacs.overrideAttrs (o: {

  # Recent tip of trunk
  # https://git.savannah.gnu.org/cgit/emacs.git/log/
  src = fetchFromSavannah {
    repo = "emacs";
    rev = "0cb511b33bc96fc30d8e5286a474b4eea54817e3";
    hash = "sha256-FCrVTAsehw+oPvMnXFXr2CHFFnk6Rw3zoucvY4f2Pq8=";
  };

  version = "30.0.50";

})
