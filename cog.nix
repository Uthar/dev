{ stdenv
, lib
, makeWrapper
, fetchFromGitHub
, meson
, ninja
, pkg-config
, wpewebkit, glib, libsoup_3, libwpe
, wpebackend-fdo
, libportal
, libepoxy
, mesa
, libinput
, cairo
, libGL
, libxkbcommon
, wayland
, wayland-protocols
, wayland-scanner
}:

# FIXME builds, but doesn't work
stdenv.mkDerivation (finalAttrs: {
  pname =  "cog";
  version = "0.18.4";
  
  src = fetchFromGitHub {
    owner = "Igalia";
    repo = "cog";
    rev = "${finalAttrs.version}";
    hash = "sha256-EucYz7Dd6XKK6EkV8e62l+mkYdA0zSGKCvSY520F59U=";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    makeWrapper
    wayland-scanner
  ];
  
  buildInputs = [
    wpewebkit glib libsoup_3 libwpe
    wpebackend-fdo
    libportal
    libepoxy
    mesa
    libinput
    cairo
    libGL
    libxkbcommon
    wayland
    wayland-protocols
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
})
