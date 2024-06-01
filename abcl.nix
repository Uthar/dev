{ lib, stdenvNoCC, fetchzip, ant, jdk, hostname }:

stdenvNoCC.mkDerivation rec {
  pname = "abcl";
  version = "1.9.2";

  src = fetchzip {
    url = "https://abcl.org/releases/${version}/abcl-src-${version}.tar.gz";
    hash = "sha256-d6DXqXfgu/L/WfoB3p4cG7Lk8higalVcCshy6XwmoL0=";
  };

  nativeBuildInputs = [ ant hostname ];
  
  buildInputs = [ jdk ];

  buildPhase = ''
    ant \
      -Dabcl.runtime.jar.path="$out/share/java/abcl.jar" \
      -Dadditional.jars="$out/share/java/abcl-contrib.jar"
  '';

  installPhase = ''
    mkdir -pv $out/share/java
    mkdir -pv $out/bin
    cp -r dist/*.jar $out/share/java
    cp abcl $out/bin
  '';
}
