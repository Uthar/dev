{ pkgsMusl, clisp, texinfo, fetchurl, ... }:

pkgsMusl.stdenv.mkDerivation rec {

  pname = "sbcl";

  version = "2.2.11";

  buildInputs = let
    zstd' = pkgsMusl.zstd.override { static = true; };
  in [
    zstd'
    zstd'.dev
    texinfo
  ];

  src = fetchurl {
    url = "mirror://sourceforge/project/sbcl/sbcl/${version}/sbcl-${version}-source.tar.bz2";
    hash = "sha256-NgfWgBZzGICEXO1dXVXGBUzEnxkSGhUCfmxWB66Elt8";
  };

  postPatch = ''
    echo '"${version}.kaspi"' > version.lisp-expr
  '';

  buildPhase = ''
    sh make.sh --prefix=$out --xc-host=${clisp}/bin/clisp --fancy --without-sb-ldb
    (cd doc/manual && make info)
  '';

  installPhase = ''
    INSTALL_ROOT=$out sh install.sh
  '';

}
