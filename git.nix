{ stdenv
, lib
, fetchFromGitHub
, installShellFiles
, sqlite
, zlib
, curl
, gettext
, expat
, openssl
, perl
, tcl
, tk
, asciidoc
, libxslt
, docbook2x
, docbook_xml_dtd_45
, texinfo
, withPerl ? false
, withTcltk ? false
, withDocs ? true
}:

let
  opts = lib.concatMapStringsSep " " (x: "${x}=y") (
    [ "INSTALL_SYMLINKS" "NO_PYTHON" ]
    ++ (lib.optional (!withPerl) "NO_PERL")
    ++ (lib.optional (!withTcltk) "NO_TCLTK")
  );
in stdenv.mkDerivation (finalAttrs: {
  name = "git";
  version = "2.45.2";
  src = fetchFromGitHub {
    owner = "uthar";
    repo = "git";
    rev = "7df17f3b76b74066f5eb8296811efaf7090d7e32";
    hash = "sha256-gGw2Z+rc8n9ftx5yjnIluwxEMW7yzDtFckcXBPK3v7w=";
  };
  nativeBuildInputs = [ installShellFiles ];
  buildInputs = [ zlib sqlite curl gettext expat openssl ]
    ++ (lib.optionals (withPerl || withDocs) [ perl ])
    ++ (lib.optionals withTcltk [ tcl tk ])
    ++ (lib.optionals withDocs [ asciidoc libxslt texinfo docbook2x docbook_xml_dtd_45 ]);
  postPatch = lib.optionalString (withPerl || withDocs) ''
    substituteInPlace Makefile --replace /usr/bin/perl ${perl}/bin/perl
  '';
  DEFAULT_HELP_FORMAT = "info";
  buildPhase = ''
    make prefix=$out ${opts} all
  '' + lib.optionalString withDocs ''
    make prefix=$out ${opts} DOCBOOK2X_TEXI=docbook2texi info
  '';
  installPhase = ''
    make prefix=$out ${opts} install
    installShellCompletion --bash contrib/completion/git-completion.bash
    installShellCompletion --zsh contrib/completion/git-completion.zsh
  '' + lib.optionalString withDocs ''
    make prefix=$out ${opts} DOCBOOK2X_TEXI=docbook2texi install-info
  '';
})
