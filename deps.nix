{ pkgs, stdenvNoCC, fetchFromGitHub, jdk, clojure, ... }:
let

  path = "src/main/clojure";

  ns = "clojure.tools.gitlibs";

  version = "v2.4.181";

  pname = "tools.gitlibs";
  
  src = fetchFromGitHub {
    owner = "clojure";
    repo = pname;
    rev = version;
    hash = "sha256-86QCuNTm5i8odZZgiehzRnXtpC8lKcybgq+rMVw6DLU=";
  };

in stdenvNoCC.mkDerivation rec {

  inherit pname version src;

  buildInputs = [ jdk clojure ];

  buildPhase = ''
    mkdir classes
    export CLASSPATH="$CLASSPATH:${path}"
    java clojure.main -e "(compile '${ns})"
  '';

  installPhase = ''
    mkdir -p $out/share/java
    (cd ${path}; jar -cf $out/share/java/${pname}-${version}.jar *)
    (cd classes; jar -uf $out/share/java/${pname}-${version}.jar *)
  '';

}
