{ stdenvNoCC, lib, testers, makeWrapper, ant, fetchFromGitHub, jdk, ... }:

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

in stdenvNoCC.mkDerivation (finalAttrs: {

  pname = "clojure";
  version = "1.12.0";

  src = fetchFromGitHub {
    owner = "clojure";
    repo = "clojure";
    rev = "clojure-${finalAttrs.version}";
    hash = "sha256-n6tHTKviB+/urrYUIfG7jKfYU9jXincdgz4cjFMXxp0=";
  };

  patches = [
    ./patches/clojure-load-compile-older-sources.patch
    ./patches/clojure-compiler-determinism.patch
    ./patches/clojure-build-spec-dependencies.patch
  ];

  postPatch = ''
    cp -r ${spec}/src/main/clojure/clojure/spec src/clj/clojure
    cp -r ${coreSpecs}/src/main/clojure/clojure/core/specs src/clj/clojure/core
  '';

  nativeBuildInputs = [ ant makeWrapper ];

  buildPhase = ''
    runHook preBuild

    ant jar

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm444 clojure.jar $out/share/java/$name.jar

    makeWrapper ${jdk}/bin/java $out/bin/clojure \
      --prefix CLASSPATH : $out/share/java/$name.jar \
      --add-flags clojure.main

    runHook postInstall
  '';

  passthru.tests.version = testers.testVersion {
    package = finalAttrs.finalPackage;
    command = "clojure -e '(clojure-version)'";
  };

  meta = {
    description = "Java based Lisp dialect";
    homepage = "https://clojure.org/";
    license = lib.licenses.epl10;
    mainProgram = "clojure";
  };
  
})
