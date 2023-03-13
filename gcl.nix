{ pkgs, stdenv, fetchFromSavannah, ... }:

stdenv.mkDerivation {
  pname = "gcl";
  version = "2.7.0pre";

  sourceRoot = "source/gcl";
  
  src = fetchFromSavannah {
    repo = "gcl";
    rev = "26a7a50d3d2ac4bc27d082f7321d16dba2b920cf";
    hash = "sha256-pKxLX1eiSjfs0aEggaaiQBbl8I9kp5gABUD8YjOM8ek=";
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
    "--enable-xdr=no"
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
