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
    rev = "d89e427852a63dbeed3d5e03d9deb2ae9a8e3e1b";
    hash = "sha256-EMkmcli0bRXVkQygyRb7QoDPVpEyG+tnTf2v2foTLRg=";
  };

  version = "30.1";

})
