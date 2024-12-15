{
  stdenv
, lib
, fetchzip
  
, cmake
, gi-docgen
, gobject-introspection
, gperf
, perl
, pkg-config
, python3
, ruby
, unifdef
 
, atk
, bubblewrap
, fontconfig
, glib
, gst-plugins-bad
, gst-plugins-base
, harfbuzz
, lcms
, libGL
, libavif
, libbacktrace
, libepoxy
, libgcrypt
, libgpg-error
, libjpeg
, libjxl
, libpng
, libseccomp
, libsoup_3
, libsysprof-capture
, libtasn1
, libwebp
, libwpe
, libxkbcommon
, libxml2
, libxslt
, mesa
, openjpeg
, sqlite
, systemd
, woff2
, xdg-dbus-proxy
}:

# WPEWebkit
#
# NOTE: Unstripped dll is 4 Gigs! (88 Meg stripped)

stdenv.mkDerivation (finalAttrs: {
  pname = "wpewebkit";
  version = "2.46.4";

  src = fetchzip {
    url = "https://wpewebkit.org/releases/wpewebkit-${finalAttrs.version}.tar.xz";
    hash = "sha256-1g5VjYCLqiwiAIPn5j2SvMzRvfT65SxE/zd3fNCvJO8=";
  };

  outputs = [ "out" "bin" "dev" "doc" ];

  cmakeFlags = [
    "-DPORT=WPE"
  ];

  nativeBuildInputs = [
    cmake
    gi-docgen
    gobject-introspection
    gperf
    perl
    pkg-config
    python3
    ruby
    unifdef
  ];

  buildInputs = [
    atk
    bubblewrap
    fontconfig
    glib
    gst-plugins-bad
    gst-plugins-base
    harfbuzz
    lcms
    libGL
    libavif
    libbacktrace
    libepoxy
    libgcrypt
    libgpg-error
    libjpeg
    libjxl
    libpng
    libseccomp
    libsoup_3
    libsysprof-capture
    libtasn1
    libwebp
    libwpe
    libxkbcommon
    libxml2
    libxslt
    mesa
    openjpeg
    sqlite
    systemd
    woff2
    xdg-dbus-proxy
  ];

  meta = {
    description = "WebKit port for Linux-based embedded devices";
    homepage = "https://wpewebkit.org/";
    license = lib.licenses.lgpl2;
  };
  
})
