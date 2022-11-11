{ pkgs, stdenvNoCC, fetchFromGitHub, fetchMavenArtifact, jdk, clojure, ... }:
let



  buildClojureLibrary = {
    pname
    ,version
    ,src
    ,path ? "src"
    ,ns ? pname
    ,deps ? []
    ,patches ? []
    , ...
  }@args : stdenvNoCC.mkDerivation (rec {

    inherit pname version src patches;

    propagatedBuildInputs = [ jdk clojure ] ++ deps;

    buildPhase = ''
      mkdir classes
      export CLASSPATH=$CLASSPATH:${path}
      java clojure.main -e "(compile '${ns})"
    '';

    installPhase = ''
      mkdir -p $out/share/java
      (cd ${path}; jar -cf $out/share/java/${pname}-${version}.jar *)
      (cd classes; jar -uf $out/share/java/${pname}-${version}.jar *)
    '';
  } // args);

  toolsGitlibs = buildClojureLibrary rec {
    pname = "tools.gitlibs";
    version = "v2.4.181";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = pname;
      rev = version;
      hash = "sha256-86QCuNTm5i8odZZgiehzRnXtpC8lKcybgq+rMVw6DLU=";
    };
    path = "src/main/clojure";
    ns = "clojure.tools.gitlibs";
  };

  toolsCli = buildClojureLibrary rec {
    pname = "tools.cli";
    version = "v1.0.214";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = pname;
      rev = version;
      hash = "sha256-ocd5ACZXF3uqRn1RPN6rHD19unP3mTYyAIZC0jhD4gA=";
    };
    path = "src/main/clojure";
    ns = "clojure.tools.cli";
  };

  toolsLogging = buildClojureLibrary rec {
    pname = "tools.logging";
    version = "v1.2.4";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = pname;
      rev = version;
      hash = "sha256-6vwtlT90GzEdnhhcdEJpBd0fJVL/2hx9+19VVY4OlO0=";
    };
    path = "src/main/clojure";
    ns = "clojure.tools.logging";
  };
  
  toolsReader = buildClojureLibrary rec {
    pname = "tools.reader";
    version = "v1.3.6";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = pname;
      rev = version;
      hash = "sha256-SICGhCl9bMIQ5b6GBlGpHvNLLdzSPNSUeOVrTwTAmGU=";
    };
    path = "src/main/clojure";
    ns = "clojure.tools.reader";
  };

  toolsAnalyzer = buildClojureLibrary rec {
    pname = "tools.analyzer";
    version = "v1.1.0";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = pname;
      rev = version;
      hash = "sha256-cAegZdNIQa43RZIoPTfRmUY64tpkUA6FmeOPrVbvj6U=";
    };
    path = "src/main/clojure";
    ns = "clojure.tools.analyzer";
  };

  toolsAnalyzerJvm = buildClojureLibrary rec {
    pname = "tools.analyzer.jvm";
    version = "v1.2.2";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = pname;
      rev = version;
      hash = "sha256-ecWRFtfjn0mpIjsJEJ/iDuiQlXzJuQtaoSgYotx+e8U=";
    };
    path = "src/main/clojure";
    ns = "clojure.tools.analyzer.jvm";
    deps = [ toolsAnalyzer coreMemoize coreCache dataPriorityMap asm toolsReader ];
  };

  toolsDepsAlpha = buildClojureLibrary rec {
    pname = "tools.deps.alpha";
    version = "v0.15.1244";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = pname;
      rev = version;
      hash = "sha256-8Vh+L2BwABU9Gz34ySoGJ1IpIPfvoP1ZZdIllq2yDJ4=";
    };
    path = "src/main/clojure";
    ns = "clojure.tools.deps.alpha";
    deps = jars ++ [
      dataXml
      toolsCli
      toolsGitlibs
      coreAsync
      toolsLogging
      coreMemoize
      toolsAnalyzer
      toolsReader
      toolsAnalyzerJvm
      coreCache
      dataPriorityMap
      awsApi
    ];
  };
 
  jars = map fetchMavenArtifact (builtins.fromJSON (builtins.readFile ./jars.json));

  toolsBuild = buildClojureLibrary rec {
    pname = "tools.build";
    version = "v0.8.1";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = pname;
      rev = version;
      hash = "sha256-nuPBuNQ4su6IAh7rB9kX/Iwv5LsV+FOl/uHro6VcL7c=";
    };
    path = "src/main/clojure";
    ns = "clojure.tools.build.api";
    deps = [ toolsDepsAlpha toolsNamespace ];
  };
  
  toolsNamespace = buildClojureLibrary rec {
    pname = "tools.namespace";
    version = "v1.3.0";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = pname;
      rev = version;
      hash = "sha256-vsUEFuXYrfhruhfEyBHQmYaEV1lSzjFzvdHizgp8IWw=";
    };
    path = "src/main/clojure";
    ns = "clojure.tools.namespace";
  };

  dataXml = buildClojureLibrary rec {
    pname = "data.xml";
    version = "v0.2.0-alpha8";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = pname;
      rev = version;
      hash = "sha256-fRBd4eSAcJWtbIWGb0EyXJTywbLOicnlkaSP3RqJ69Y=";
    };
    path = "src/main/clojure";
    ns = "clojure.data.xml";
  };

  dataJson = buildClojureLibrary rec {
    pname = "data.json";
    version = "v2.4.0";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = pname;
      rev = version;
      hash = "sha256-JQsLDr028FLfpZvtts0d2oLlaFBYjUc8gTdnYXyEo/c=";
    };
    path = "src/main/clojure";
    ns = "clojure.data.json";
  };

  dataPriorityMap = buildClojureLibrary rec {
    pname = "data.priority-map";
    version = "v1.1.0";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = pname;
      rev = version;
      hash = "sha256-oE4f4xlp/Y+LfGVj92u5K9Dkm63JIB1zVXtQ8VJx1cQ=";
    };
    path = "src/main/clojure";
    ns = "clojure.data.priority-map";
  };
  
  awsApi = buildClojureLibrary rec {
    pname = "aws-api";
    version = "v0.8.612";
    src = fetchFromGitHub {
      owner = "cognitect-labs";
      repo = pname;
      rev = version;
      hash = "sha256-YDHyzDq9hDkfaSULqu1QKYz7QPuRPLFK2nZn0aQPcTQ=";
    };
    ns = "cognitect.aws.client.api";
    deps = [ dataXml dataJson toolsLogging coreAsync ];
  };
  
  coreAsync = buildClojureLibrary rec {
    pname = "core.async";
    version = "v1.6.673";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = pname;
      rev = version;
      hash = "sha256-1kY/aTli9CnyhXI0ZwT6wlLFfGRGayA/4QSK21sWjv8=";
    };
    path = "src/main/clojure";
    ns = "clojure.core.async";
    deps = [ toolsAnalyzerJvm ];
  };
  
  coreCache = buildClojureLibrary rec {
    pname = "core.cache";
    version = "v1.0.225";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = pname;
      rev = version;
      hash = "sha256-1ByBxHVTIqFHukEp9fk/eHQOWP3PP7KXaas5dzy9Ibc=";
    };
    path = "src/main/clojure";
    ns = "clojure.core.cache";
    deps = [ dataPriorityMap ];
  };

  coreMemoize = buildClojureLibrary rec {
    pname = "core.memoize";
    version = "v1.0.257";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = pname;
      rev = version;
      hash = "sha256-XvkjzRKB/gAN2nXcq9IEF6cwtX9DNlZft6UZjzcsiG4=";
    };
    path = "src/main/clojure";
    ns = "clojure.core.memoize";
    deps = [ coreCache dataPriorityMap ];
  };

  asm = fetchMavenArtifact {
    groupId = "org.ow2.asm";
    artifactId = "asm";
    version = "9.2";
    hash = "sha256-udT+TXGTjfOIOfDspCqqpkz4sxPWeNoDbwyzyhmbR/U=";
  };

  javaClasspath = buildClojureLibrary rec {
    pname = "java.classpath";
    version = "1.1.0";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = pname;
      rev = "c93196693a1705421d88c30120fb773941414c90";
      hash = "sha256-kguqLNmxt1aZggExnIrkEbRpDtufjsMFalOnsB+rlzU=";
    };
    path = "src/main/clojure";
    ns = "clojure.java.classpath";
  };

  brewInstall = buildClojureLibrary {
    pname = "exec";
    version = clojure.version;
    src = fetchFromGitHub {
      owner = "clojure";
      repo = "brew-install";
      rev = clojure.version;
      hash = "sha256-Au5Yu9qgIyL5dDV3vHm8FdXjjnJsKgB8UmqUYF4z9tc=";
    };
    path = "src/main/clojure";
    ns = "clojure.run.exec";
  };

  


in brewInstall
