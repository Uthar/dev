{ pkgs, stdenv, fetchFromGitHub, ... }:

stdenv.mkDerivation {
  pname = "gcl";
  version = "2.7.0pre";

  sourceRoot = "source/gcl";
  
  src = fetchFromGitHub {
    owner = "Uthar";
    repo = "gcl";
    rev = "288f9d0b08b5a09ef483bd9c29a8ccfea0a80b29";
    hash = "sha256-qExkff795m00r5gXjgWmD9wFWW+abVUPaGIerYsgQmQ=";
  };

  # breaks when compiling in parallel
  enableParallelBuilding = false;

  buildInputs = with pkgs; [
    m4
    mpfr
    gmp    
    zlib
    texinfo
    readline
    libtirpc
  ];

  configureFlags = [
    "--enable-ansi"
  ];

  NIX_CFLAGS_COMPILE = [
    "-isystem"
    "${pkgs.libtirpc.dev}/include/tirpc"
  ];

  NIX_LDFLAGS = [
    "-ltirpc"
  ];

  hardeningDisable = [ "all" ];

  dontFixup = true;
  dontStrip = true;

}
