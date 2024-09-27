{ lib, stdenv, fetchFromGitHub, ... }:

stdenv.mkDerivation (finalAttrs: {
  pname = "adhocify";
  version = "trunk";
  src = fetchFromGitHub {
    owner = "quitesimpleorg";
    repo = "adhocify";
    rev = "25fe05e702ac83059db6a14d432bf2998f990caa";
    hash = "sha256-OdfvcEeqHXDEj7uyHcQR9OEYA3LjeaOLt4ofI97swl0=";
  };
  postPatch = ''
    substituteInPlace Makefile --replace /usr/local $out
  '';
  meta = {
    description = "Tool which monitors for file system events using inotify.";
    mainProgram = "adhocify";
    license = lib.licenses.mit;
  };
})
