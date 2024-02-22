{ pkgs, lib, stdenv
, meson
, ninja
, pkg-config
, cmake
, wayland
, libwpe
, epoxy
, glib
, libxkbcommon
, libGL
, ... }:

{

  fdo = stdenv.mkDerivation {
    pname = "WPEBackend-fdo";
    version = "trunk";
    src = pkgs.fetchFromGitHub {
      owner = "Igalia";
      repo = "WPEBackend-fdo";
      rev = "f2901c6ed7f720a578bfd5830d12426c979c0afa";
      hash = "sha256-8Vse/n4FSs97NtTfkrdzpd+I0/LYVOGgn+U6qNpPG5E=";
    };
    buildInputs = [
      pkg-config
      meson
      ninja
      wayland
      libwpe
      epoxy
      glib
      libxkbcommon
      libGL.dev
    ];
    configurePhase = ''
      meson setup -Dprefix=$out build
    '';
    buildPhase = ''
      ninja -C build
    '';
    installPhase = ''
      ninja install -C build
    '';
  };

}
