{ stdenv
, lib
, fetchFromGitHub
, meson
, ninja
, pkg-config
, cmake
, wayland
, wayland-scanner
, libwpe
, libepoxy
, glib
, libxkbcommon
, libGL
}:

{

  wpebackend-fdo = stdenv.mkDerivation (finalAttrs: {
    pname = "WPEBackend-fdo";
    version = "1.14.3";
    
    src = fetchFromGitHub {
      owner = "Igalia";
      repo = "WPEBackend-fdo";
      rev = "${finalAttrs.version}";
      hash = "sha256-K5jp6dlQIs8FRdNHlK8IRkJHB9HW300HLtbcN0U1RhY=";
    };
    
    nativeBuildInputs = [
      pkg-config
      meson
      ninja
      wayland-scanner
    ];
    
    buildInputs = [
      wayland
      libwpe
      libepoxy
      glib
      libxkbcommon
      libGL
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
  });

}
