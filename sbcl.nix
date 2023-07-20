{ pkgs, lib, stdenv, zstd, texinfo, fetchurl, sqlite, libuv, fat, ... }:

stdenv.mkDerivation rec {

  pname = "sbcl";

  version = "2.3.6";

  buildInputs = let
    zstd' = zstd.override { static = true; };
  in [
    zstd'
    zstd'.dev
    texinfo
  ];

  src = fetchurl {
    url = "mirror://sourceforge/project/sbcl/sbcl/${version}/sbcl-${version}-source.tar.bz2";
    hash = "sha256-tEFMpNmnR06NiE19YyN+LynvRZ39WoSEJKnD+lUdGbk=";
  };

  postPatch = ''
    echo '"${version}.kaspi"' > version.lisp-expr
  '' + (lib.optionalString fat ''
    echo -n 'LINKFLAGS+=-Wl,--whole-archive ' >> src/runtime/Config.x86-64-linux
    echo -n '${sqlite}/lib/libsqlite3.a ' >> src/runtime/Config.x86-64-linux
    echo '-Wl,--no-whole-archive' >> src/runtime/Config.x86-64-linux
    echo -n 'LINKFLAGS+=-Wl,--whole-archive ' >> src/runtime/Config.x86-64-linux
    echo -n '${libuv}/lib/libuv.a ' >> src/runtime/Config.x86-64-linux
    echo '-Wl,--no-whole-archive' >> src/runtime/Config.x86-64-linux
  '');

  buildPhase = ''
    sh make.sh --prefix=$out --xc-host=${pkgs.sbclBootstrap}/bin/sbcl --fancy --without-sb-ldb --with-sb-linkable-runtime
    (cd doc/manual && make info)
  '';

  installPhase = ''
    INSTALL_ROOT=$out sh install.sh
  '';

}
