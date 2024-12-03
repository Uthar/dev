{
  stdenv,
  lib,
  testers,
  # buildEnv,
  makeWrapper,
  fetchzip,
  # fetchgit,
  jdk,
}:

let

  # hamcrest = stdenv.mkDerivation (finalAttrs: {
  #   pname = "hamcrest-java";
  #   version = "3.0";
  #   
  #   src = fetchgit {
  #     url = "https://github.com/hamcrest/JavaHamcrest";
  #     rev = "v${finalAttrs.version}";
  #     hash = "sha256-5TExhZ7deu1meYSEeYiqt7at2BmFFLiXPBDPwgcNHgc=";
  #     postFetch = ''
  #       find $out -name '*.jar' -print -delete
  #     '';
  #   };
  #   
  #   nativeBuildInputs = [ jdk ];
  #   
  #   buildPhase = ''
  #     find hamcrest/src/main/java -name '*.java' -fprint src.txt
  #     javac -d classes @src.txt
  #   '';
  #   
  #   installPhase = ''
  #     mkdir -pv $out/share/java
  #     jar -c --date=2000-01-01T00:00:00Z -f $out/share/java/$name.jar -C classes .
  #   '';
  # 
  #   meta = {
  #     description = "Java assertions library";
  #     homepage = "https://hamcrest.org/";
  #     license = lib.licenses.bsd3;
  #   };
  # });
  # 
  # junit = stdenv.mkDerivation (finalAttrs: {
  #   pname = "junit";
  #   version = "4.13.2";
  # 
  #   src = fetchgit {
  #     url = "https://github.com/junit-team/junit4";
  #     rev = "r${finalAttrs.version}";
  #     hash = "sha256-ylT7dEY7rAXD+geG0lBZDZkcnnLUDOLet8E8fPclWh0=";
  #     postFetch = ''
  #       find $out -name '*.jar' -print -delete
  #     '';
  #   };
  #   
  #   nativeBuildInputs = [ jdk ];
  #   propagatedBuildInputs = [ hamcrest ];
  #   propagatedUserEnvPkgs = finalAttrs.propagatedBuildInputs;
  # 
  #   # ZRÓB: upstream
  #   postPatch = ''
  #     substituteInPlace src/main/java/org/junit/internal/matchers/*.java \
  #       --replace '@Factory' ' ' \
  #       --replace 'import org.hamcrest.Factory' ' '
  # 
  #     substituteInPlace src/main/java/org/junit/matchers/JUnitMatchers.java \
  #       --replace \
  #         'Matcher<Iterable<T>> everyItem' \
  #         'Matcher<Iterable<? extends T>> everyItem'
  #   '';
  #    
  #   buildPhase = ''
  #     find src/main/java -name '*.java' -fprint src.txt
  #     javac -d classes @src.txt
  #   '';
  #   
  #   installPhase = ''
  #     mkdir -pv $out/share/java
  #     jar -c --date=2000-01-01T00:00:00Z -f $out/share/java/$name.jar -C classes .
  #   '';
  # 
  #   meta = {
  #     description = "Java unit testing framework";
  #     homepage = "https://junit.org/junit4/";
  #     license = lib.licenses.epl10;
  #   };
  # });

  ant = stdenv.mkDerivation (finalAttrs: {
    pname = "ant";
    version = "1.10.15";

    src = fetchzip {
      url = "mirror://apache/ant/source/apache-ant-${finalAttrs.version}-src.tar.gz";
      hash = "sha256-DjUV5H9OdKOAzCIiotB7bwZoCW6HPCJE675QgD12wuw=";
      postFetch = ''
        find $out/lib -name '*.jar' -print -delete
      '';
    };

    nativeBuildInputs = [ jdk makeWrapper ];

    # propagatedBuildInputs = [ junit ];

    patches = [
      # ZRÓB: upstream
      ./patches/ant-do-not-build-empty-jars.patch
      ./patches/ant-zip-obey-source-date-epoch.patch
    ];

    # Bootstrap then rebuild with yourself
    buildPhase = ''
      runHook preBuild

      addToSearchPath CLASSPATH src/main

      javac \
        src/main/org/apache/tools/bzip2/*.java \
        src/main/org/apache/tools/tar/*.java \
        src/main/org/apache/tools/zip/*.java \
        src/main/org/apache/tools/ant/util/regexp/RegexpMatcher.java \
        src/main/org/apache/tools/ant/util/regexp/RegexpMatcherFactory.java \
        src/main/org/apache/tools/ant/property/*.java \
        src/main/org/apache/tools/ant/types/*.java \
        src/main/org/apache/tools/ant/types/resources/*.java \
        src/main/org/apache/tools/ant/*.java \
        src/main/org/apache/tools/ant/taskdefs/*.java \
        src/main/org/apache/tools/ant/taskdefs/compilers/*.java \
        src/main/org/apache/tools/ant/taskdefs/condition/*.java

      java org.apache.tools.ant.Main -Dbuild.sysclasspath=only jars

      runHook postBuild
    '';

    # Dlaczego nie widzi junita gdy jest w $HOME/.ant?
    # https://bz.apache.org/bugzilla/show_bug.cgi?id=6606
    #
    # System classloader nie widzi URLClassLoadera którego tworzy Launcher.
    # Dlatego jeśli nawet tylko junit ant task jest na classpathie, to również
    # sam junit musi na niej być.
    #
    # Z tego powodu trzeba albo dodać junita do pierwotnej CLASSPATH, albo
    # porozdzielać optional jary z ant taskami, tak aby i one były ładowane
    # przez URLClassLoader.
    installPhase = let
      # jars = buildEnv {
      #   name = "jars";
      #   pathsToLink = [ "/share/java" ];
      #   paths = finalAttrs.propagatedBuildInputs;
      # };
    in ''
      runHook preInstall

      install -Dm444 build/lib/{ant,ant-launcher}.jar -t $out/share/ant

      makeWrapper ${jdk}/bin/java $out/bin/ant \
        --add-flags "-jar $out/share/ant/ant-launcher.jar"

      runHook postInstall
    '';

    passthru.tests.version = testers.testVersion {
      package = finalAttrs.finalPackage;
      command = "ant -version";
    };

    meta = {
      description = "Java-based build tool";
      homepage = "https://ant.apache.org/";
      license = lib.licenses.asl20;
      mainProgram = "ant";
    };
  });

in ant
