{ stdenv,
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
  ... }:

stdenv.mkDerivation {
  pname = "i3";
  version = "trunk";

  src = fetchgit {
    url = "https://github.com/uthar/i3";
    rev = "b46ae7e55b33becff357aa59444204625b390ab4";
    hash = "sha256-jK8DRE8u+2w2hLMC5GehnuTHgxfAD0ArcniUzXBkQV8=";
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

}
