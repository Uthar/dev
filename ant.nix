{ pkgs, jdk, stdenvNoCC, fetchFromGitHub, ... }:

stdenvNoCC.mkDerivation rec {
  pname = "ant";
  version = "1.10.14";

  src = fetchFromGitHub {
    owner = "apache";
    repo = "ant";
    rev = "rel/${version}";
    hash = "sha256-nt81VDsC+jFEgxQZ8acsDW17TozZiAIXL2u+4g+EpMw=";
  };

  buildInputs = [ jdk ];

  buildPhase = ''
    mkdir $out
    sh build.sh -Dant.install=$out install-lite
  '';

  dontInstall = true;

}
