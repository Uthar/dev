{ pkgs, stdenvNoCC, ant, fetchFromGitHub, jdk, ... }:
let

  spec = fetchFromGitHub {
    owner = "clojure";
    repo = "spec.alpha";
    rev = "v0.5.238";
    hash = "sha256-aIZPqKKO/OEmpJHe7VZsdqZF347IaqbPB7vkLQShncw=";
  };

  coreSpecs = fetchFromGitHub {
    owner = "clojure";
    repo = "core.specs.alpha";
    rev = "v0.4.74";
    hash = "sha256-VqBSQFjidH4f4cQ2wFseIjKO/UoO2tim4vN3vOPwxUk=";
  };

in stdenvNoCC.mkDerivation rec {

  pname = "clojure";
  version = "1.12.0-beta1";

  src = fetchFromGitHub {
    owner = "clojure";
    repo = "clojure";
    rev = "clojure-${version}";
    hash = "sha256-JhJHXPON35VWu4su3VwX7NYWI8gm7gpMnYvrF2CuI14=";
  };

  patches = [ ./patches/clojure-build-spec-dependencies.patch ];

  nativeBuildInputs = [ ant jdk ];

  buildPhase = ''
    cp -r ${spec}/src/main/clojure/clojure/spec src/clj/clojure
    cp -r ${coreSpecs}/src/main/clojure/clojure/core/specs src/clj/clojure/core
    ant build jar
  '';

  installPhase = ''
    mkdir -p $out/share/java
    cp -v clojure-${version}.jar $out/share/java
  '';

}
