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
    rev = "a412d3c46cc4e53a78793dd4e129918452516caa";
    hash = "sha256-QyGZ4BBV2xBr5bElojC73a676ZzCmrLplAe6t9hMFZE=";
  };

  version = "30.0.50";

})
