{ pkgs, pkgsMusl, ... }:

pkgsMusl.stdenv.mkDerivation rec {
  pname = "mg";
  version = "3.7";

  src = pkgs.fetchFromGitHub {
    owner = "troglobit";
    repo = "mg";
    rev = "v${version}";
    hash = "sha256-+tnBWNu6BzSSYE2xLM6mudG5SzhyPi6SdrW7XmtFkfs=";
  };

  outputs = [ "out" "doc" ];

  buildInputs = [
    pkgs.autoconf
    pkgs.automake
  ];

  preConfigure = ''
    ./autogen.sh
  '';

  configureFlags = [
    "--without-curses"
    "LDFLAGS=-static"
  ];
}
