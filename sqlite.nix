{ stdenv, fetchurl, zlib, readline, ... }:

stdenv.mkDerivation rec {
  pname = "sqlite";
  version = "3.45.0";

  # https://sqlite.org/news.html
  src = fetchurl {
    url = "https://sqlite.org/2024/sqlite-autoconf-3450000.tar.gz";
    hash = "sha256-coh9V6HY+J9SvjjvhKY1POjD7VWtp4ZOuUSr2aSV5DY=";
  };

  buildInputs = [ zlib readline ];

  configureFlags = [ "--enable-threadsafe" "--enable-readline" ];

  dontDisableStatic = true;

  NIX_CFLAGS_COMPILE = toString ([
    "-DSQLITE_ENABLE_COLUMN_METADATA"
    "-DSQLITE_ENABLE_DBSTAT_VTAB"
    "-DSQLITE_ENABLE_JSON1"
    "-DSQLITE_ENABLE_FTS3"
    "-DSQLITE_ENABLE_FTS3_PARENTHESIS"
    "-DSQLITE_ENABLE_FTS3_TOKENIZER"
    "-DSQLITE_ENABLE_FTS4"
    "-DSQLITE_ENABLE_FTS5"
    "-DSQLITE_ENABLE_RTREE"
    "-DSQLITE_ENABLE_STMT_SCANSTATUS"
    "-DSQLITE_ENABLE_UNLOCK_NOTIFY"
    "-DSQLITE_SECURE_DELETE"
    "-DSQLITE_MAX_VARIABLE_NUMBER=250000"
    "-DSQLITE_MAX_EXPR_DEPTH=10000"
  ]);
   
}
