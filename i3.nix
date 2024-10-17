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
    rev = "c0f0b2fe0fce25700a45803121c3280e6515a6e4";
    hash = "sha256-ANMgAxO1e0hLfZ/onfqA2BVFYrMdmInp9GkfDp9DFXw=";
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
