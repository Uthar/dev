{
  stdenv,
  lib,
  fetchgit,
  ninja,
  meson,
  pkg-config,
  libstartup_notification,
  libxcb,
  xcbutil,
  xcb-util-cursor,
  xcbutilkeysyms,
  xcbutilwm,
  xcbutilxrm,
  libxkbcommon,
  yajl,
  pcre2,
  pango,
  libev,
  perl,
}:

stdenv.mkDerivation {
  pname = "i3";
  version = "trunk";

  src = fetchgit {
    url = "https://github.com/uthar/i3";
    rev = "83abce397d6f2777ca6a4f4ca8e05d43d183a785";
    hash = "sha256-gOt39saODmXnRl5gTD1buGHkER6WJnGiGP+1/JZYoQU=";
  };

  mesonFlags = [ "--reconfigure" ];

  postPatch = ''
    patchShebangs .
  '';

  nativeBuildInputs = [
    ninja meson pkg-config perl
  ];

  buildInputs = [
    libxcb xcbutil xcb-util-cursor xcbutilkeysyms xcbutilwm xcbutilxrm
    libxkbcommon yajl pcre2 pango libev libstartup_notification
  ];

  meta = {
    description = "Tiling window manager";
    homepage = "https://i3wm.org/";
    license = lib.licenses.bsd3;
    mainProgram = "i3";
  };
}
