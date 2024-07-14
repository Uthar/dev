{ lib, stdenv
, installShellFiles
, tcl
, libiconv
, fetchurl
, fetchpatch
, zlib
, openssl
, readline
, ed
, which
, tcllib
}:

stdenv.mkDerivation rec {
  pname = "fossil";
  version = "2.24";

  src = let
    rev = "version-${version}";
  in fetchurl {
    url = "https://www.fossil-scm.org/home/tarball/${rev}/fossil-${rev}.tar.gz";
    sha256 = "sha256-3f0hkoTjF/KmhEFsqezWuMf62XfFdQGiDLtz76Q3piE=";
  };

  configureFlags = [
    "--json"
  ];

  nativeBuildInputs = [ installShellFiles tcl tcllib ];

  buildInputs = [ zlib openssl readline which ed ];

  enableParallelBuilding = true;

  preBuild = ''
    export USER=nonexistent-but-specified-user
  '';

  installPhase = ''
    mkdir -p $out/bin
    INSTALLDIR=$out/bin make install
    installManPage fossil.1
  '';

}
