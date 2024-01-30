{

  description = "WebKit";

  outputs = { self, nixpkgs }: let
    systems = ["x86_64-linux"];
  in {
    devShells = nixpkgs.lib.genAttrs systems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = pkgs.mkShell {
        # cmake -DPORT=WPE -DENABLE_WPE_PLATFORM_WAYLAND=OFF -DENABLE_BUBBLEWRAP_SANDBOX=OFF -DENABLE_VIDEO=OFF -DENABLE_WEB_AUDIO=OFF -DENABLE_WEBGL=OFF -GNinja
        # ninja
        packages = with pkgs; [
          pkg-config
          cmake
          ninja
          python3
          ruby
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
          gobject-introspection
          libsoup_3
          gi-docgen
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
          gperf
          libGL
        ];
      };
    });
  };

}
  
