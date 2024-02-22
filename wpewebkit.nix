{ stdenv, pkgs, ...}:

# WPEWebkit
#
# NOTE: Unstripped dll is 4 Gigs! (88 Meg stripped)

stdenv.mkDerivation rec {
  
  pname = "wpewebkit";
  version = "2.43.1";

  # src = pkgs.fetchFromGitHub {
  #   owner = "WebKit";
  #   repo = "WebKit";
  #   rev = "5d4d9c7ef39a8e0c948023df3eefb440070c3999";
  #   hash = "";
  # };

  src = pkgs.fetchzip {
    url = "https://wpewebkit.org/releases/wpewebkit-${version}.tar.xz";
    hash = "sha256-UZFQE3pBeyLZaCp+Jh0fwfwkyBj7GWh8dN3y5e8sfY4=";
  };

  cmakeFlags = [
    "-DPORT=WPE"
    "-DENABLE_WPE_PLATFORM_WAYLAND=OFF"
    "-DENABLE_BUBBLEWRAP_SANDBOX=OFF"
    # Had to add gstreamer anyways because of hardcoding
    # "-DENABLE_VIDEO=OFF"
    # "-DENABLE_WEB_AUDIO=OFF"
    "-DENABLE_WEBGL=OFF"
    "-GNinja"
    # Next try with these:
    # "-DENABLE_ACCESSIBILITY=OFF"
    # "-DENABLE_GAMEPAD=OFF"
    # "-DENABLE_INTROSPECTION=OFF"
    # "-DENABLE_JOURNALD_LOG=OFF"
    # "-DENABLE_OFFSCREEN_CANVAS=ON"
    # "-DENABLE_OFFSCREEN_CANVAS_IN_WORKERS=ON"
    # "-DENABLE_PDFJS=OFF"
    # "-DENABLE_WEBDRIVER=OFF"
    # "-DUSE_AVIF=OFF"
    # "-DENABLE_WPE_QT_API=OFF"
    # "-DENABLE_COG=OFF"
    # "-DENABLE_MINIBROWSER=OFF"
    # "-DENABLE_WPEBACKEND_FDO_AUDIO_EXTENSION=OFF"
  ];

  nativeBuildInputs = with pkgs; [
    pkg-config
    cmake
    ninja
    python3
    ruby
    perl
    gobject-introspection
    gi-docgen
    gperf
  ];

  buildInputs = with pkgs; [
    atk
    cairo
    fontconfig
    freetype
    harfbuzzFull
    icu
    libjpeg
    epoxy
    libgcrypt
    libgpg-error
    libtasn1
    libxkbcommon
    libxml2
    libpng
    sqlite
    unifdef
    libwebp
    libwpe
    zlib
    libsoup_3
    libjxl
    openjpeg
    woff2
    libxslt
    libinput
    udev
    libavif
    lcms2
    libdrm
    mesa.dev
    libbacktrace
    libGL
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-bad
  ];
  
}

