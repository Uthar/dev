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
, python3
, tcl
, tk
, asciidoc
, xmlto
, docbook_xsl
, docbook_xml_dtd_45
, withPython ? false
, withPerl ? false
, withTcltk ? false
, withMan ? true
}:

stdenv.mkDerivation (finalAttrs: {
  name = "git";
  version = "2.45.2";
  
  src = fetchFromGitHub {
    owner = "uthar";
    repo = "git";
    rev = "7df17f3b76b74066f5eb8296811efaf7090d7e32";
    hash = "sha256-gGw2Z+rc8n9ftx5yjnIluwxEMW7yzDtFckcXBPK3v7w=";
  };
  
  nativeBuildInputs = [ installShellFiles ]
    ++ (lib.optionals withMan [ perl ])
    ++ (lib.optionals withMan [ asciidoc xmlto docbook_xsl docbook_xml_dtd_45 ]);
  
  buildInputs = [ zlib sqlite curl gettext expat openssl ]
    ++ (lib.optionals withPerl [ perl ])
    ++ (lib.optionals withPython [ python3 ])
    ++ (lib.optionals withTcltk [ tcl tk ]);
  
  makeFlags = [ "INSTALL_SYMLINKS=y" ]
    ++ (lib.optional (withPython) "PYTHON_PATH=${python3}/bin/python")
    ++ (lib.optional (withPerl || withMan) "PERL_PATH=${perl}/bin/perl")
    ++ (lib.optional (!withPython) "NO_PYTHON=y")
    ++ (lib.optional (!withPerl) "NO_PERL=y")
    ++ (lib.optional (!withTcltk) "NO_TCLTK=y");
  
  preBuild = ''
    makeFlagsArray+=("prefix=$out")
  '';
  
  buildFlags = [ "all" ]
    ++ (lib.optional withMan "man");

  installTargets = [ "install" ]
    ++ (lib.optional withMan "install-man");

  postInstall = ''
    installShellCompletion --cmd git --bash contrib/completion/git-completion.bash
    installShellCompletion --cmd git --zsh contrib/completion/git-completion.zsh
  '';
})
