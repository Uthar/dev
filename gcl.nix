{ stdenv
, lib
, fetchFromSavannah
, autoconf
, automake
, m4
, mpfr
, gmp
, zlib
, texinfo
, readline
, libtirpc
, withTk ? true, tk
, withX ? true, libXmu, libXaw
, ... }:

assert withTk -> tk != null;
assert withX -> libXmu != null && libXaw != null;

stdenv.mkDerivation {
  pname = "gcl";
  version = "2.7.0pre26";

  sourceRoot = "source/gcl";
  
  src = fetchFromSavannah {
    repo = "gcl";
    rev = "0fc02b307794501a46b26ca2a175065786ad7c0d";
    hash = "sha256-xBdiwsx1s803x7quVuPVT3Ubb80IMvr4En4WT5swkGQ=";
  };

  # breaks when compiling in parallel
  enableParallelBuilding = false;

  nativeBuildInputs = [
    autoconf automake
  ];
  
  buildInputs = [
    m4
    mpfr
    gmp    
    zlib
    texinfo
    readline
    libtirpc
  ] ++ (lib.optionals withX [ libXmu libXaw ])
  ++ (lib.optionals withTk [ tk ]);

  preConfigure = ''
    autoreconf -fvi
  '';
  
  configureFlags = [
    "--enable-ansi"
    # --disable-statsysbfd #def=no
		# --disable-custreloc #def=no
		# --disable-prelink #def=no
		# --disable-pargcl #def=no
		# --enable-dlopen #def=yes
    (lib.enableFeature withX "xgcl")
    (lib.enableFeature withTk "tcltk")
  ];

  NIX_CFLAGS_COMPILE = [
    "-isystem"
    "${libtirpc.dev}/include/tirpc"
  ];

  NIX_LDFLAGS = [
    "-ltirpc"
  ];

  hardeningDisable = [ "all" ];

  dontFixup = true;
  dontStrip = true;

}
