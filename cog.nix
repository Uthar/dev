{ pkgs, lib, stdenv
, makeWrapper
, meson
, ninja
, pkg-config
, wpewebkit
, wpebackend-fdo
, libportal
, wayland
, wayland-protocols
, ... }:

# FIXME builds, but doesn't work
stdenv.mkDerivation {
  pname =  "cog";
  version = "0.18.2-trunk";
  src = pkgs.fetchFromGitHub {
    owner = "Igalia";
    repo = "cog";
    rev = "dd2012a1461b10b914da1eacc2d6fc423d07fffc";
    hash = "sha256-H+qWAT6fUHrlAjQEyLbz+BdwxoeP68WdpMTR6iaCHHc=";
  };
  buildInputs = with pkgs; [
    meson
    ninja
    pkg-config
    wpewebkit
    wpebackend-fdo
    libportal
    wayland
    wayland-protocols
    makeWrapper

    # TODO should be in propagatedBuildInputs of wpewebkit
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
  configurePhase = ''
    meson setup -Dprefix=$out build
  '';
  buildPhase = ''
    ninja -C build
  '';
  installPhase = ''
    ninja install -C build
    wrapProgram $out/bin/cog \
      --prefix LD_LIBRARY_PATH : ${wpebackend-fdo}/lib
  '';
}
