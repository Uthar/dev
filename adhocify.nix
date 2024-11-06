{ lib, stdenv, fetchgit, ... }:

stdenv.mkDerivation (finalAttrs: {
  pname = "adhocify";
  version = "trunk";
  src = fetchgit {
    url = "https://github.com/Uthar/adhocify";
    rev = "5999e125e73bc5eb3b416217c5e2f419acae65e6";
    hash = "sha256-BoQRVIz46np5OPX+6cw6UPSihc4CSW5k3Vd1icSgX2A=";
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
