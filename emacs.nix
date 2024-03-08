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
    rev = "345cdd7a70558cd47c2ab3e124e2352debaa57cb";
    hash = "sha256-U+lS32TeDicfdbpiL2mEorWIcWM41hamugcwdtfRe90=";
  };

  version = "30.1";

})
