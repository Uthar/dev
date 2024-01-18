{ pkgs, fetchFromSavannah, sqlite, tree-sitter, ... }:

let

  emacs = pkgs.emacs.override {
    inherit sqlite;
    withSQLite3 = true;
    withTreeSitter = true;
    withNativeCompilation = false; # Takes too long
  };

in emacs.overrideAttrs (o: {

  # Recent tip of trunk
  # https://git.savannah.gnu.org/cgit/emacs.git/log/
  src = fetchFromSavannah {
    repo = "emacs";
    rev = "5f5faad249747ce5bd4b7f2968f737206c136265";
    hash = "sha256-VSyevS5yNBH3K2MEUWD17CFFBMZby5p2rdjbWLCZuQ0=";
  };

  version = "30.0.50";

})
