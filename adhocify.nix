{ lib, stdenv, fetchFromGitHub, ... }:

stdenv.mkDerivation (finalAttrs: {
  pname = "adhocify";
  version = "trunk";
  src = fetchFromGitHub {
    owner = "Uthar";
    repo = "adhocify";
    rev = "69fdb239440403527bd25c79290f3ef26104926d";
    hash = "sha256-ndPEhLoGSOZhbGJa43FKdmlZyappLLtyqNNjMAOFBu4=";
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
