{ stdenv
, lib
, fetchzip
, installShellFiles
, tcl
, tcllib
, zlib
, openssl
, readline
}:

stdenv.mkDerivation (finalAttrs: {
  
  pname = "fossil";
  version = "735bd3dccbeecada15611a1eacf76d2b9822f44223a918282ac4eab0acb78c5f";

  src = fetchzip {
    url = "https://www.fossil-scm.org/home/tarball/${finalAttrs.version}/fossil-${finalAttrs.version}.tar.gz";
    hash = "sha256-Q0wfx0W3N6nCh6HdxOnK5wI2doENeuOVqGqwCqRpnTw=";
  };

  configureFlags = ["--json"];

  nativeBuildInputs = [ installShellFiles tcl tcllib ];

  buildInputs = [ zlib openssl readline ];

  postInstall = ''
    installManPage fossil.1
    installShellCompletion --bash tools/fossil-autocomplete.bash
    installShellCompletion --zsh tools/fossil-autocomplete.zsh
  '';

  meta = {
    description = "Distributed SCM system";
    homepage = "https://fossil-scm.org/";
    license = lib.licenses.bsd2;
    mainProgram = "fossil";
  };
  
})
