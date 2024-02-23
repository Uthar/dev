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
