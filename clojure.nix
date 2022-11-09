{ pkgs, stdenvNoCC, ant, fetchFromGitHub, jdk, ... }:
let

  spec = fetchFromGitHub {
    owner = "clojure";
    repo = "spec.alpha";
    rev = "v0.3.218";
    sha256 = "02dl34msr55s1rc4ggj7r4frggzr93dbam4082y3h5y2gcibfac6";
  };

  coreSpecs = fetchFromGitHub {
    owner = "clojure";
    repo = "core.specs.alpha";
    rev = "v0.2.62";
    sha256 = "1nfqwxf2in6jkfvsd9is2zwls2izfz0r942iflwlrzzr6ba1279d";
  };

in stdenvNoCC.mkDerivation rec {

  pname = "clojure";
  version = "1.11.1";

  src = fetchFromGitHub {
    owner = "clojure";
    repo = "clojure";
    rev = "clojure-${version}";
    sha256 = "1xbab21rm9zvhmw1i2h5lqm7612vrdkxprq0rgb2i3sbgsxcdsn4";
  };

  patches = [ ./patches/clojure-build-spec-dependencies.patch ];

  buildInputs = [ ant jdk ];

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
