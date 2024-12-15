{
  description = "Development environment";

  inputs.nixpkgs.url = "nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }: let
    systems = ["x86_64-linux"];
    lib = nixpkgs.lib;
  in {
    devShells = lib.genAttrs systems (system: let
      pkgs = nixpkgs.outputs.legacyPackages.${system};
      sbcl' = pkgs.sbcl.withPackages (ps: with ps; [
        alexandria bordeaux-threads cl-cpus jzon
      ]);
    in {
      default = pkgs.mkShell {
        packages = [ sbcl' ];
      };
    });
    
    packages = lib.genAttrs systems (system: let
      pkgs = nixpkgs.outputs.legacyPackages.${system};
    in {
      git = pkgs.callPackage ./git.nix {
        inherit (self.packages.${system}) sqlite;
      };
      jdk = pkgs.jdk17;
      jdk_minimal = pkgs.jdk17.override {
        headless = true;
        enableJavaFX = false;
        enableGtk = false;
      };
      jre_minimal = pkgs.jre_minimal.override {
        jdk = self.packages.${system}.jdk_minimal;
      };
      jre_docker = pkgs.dockerTools.buildImage {
        name = "jre";
        tag = "latest";
        contents = [
          self.packages.${system}.jdk_minimal
        ];
      };
      jdk_musl = pkgs.pkgsMusl.jdk17.override {
        headless = true;
        enableJavaFX = false;
        enableGtk = false;
      };
      jdk_musl_minimal = pkgs.pkgsMusl.jre_minimal.override {
        jdk = self.packages.${system}.jdk_musl;
      };
      jdk_musl_docker = pkgs.dockerTools.buildImage {
        name = "jre";
        tag = "musl";
        contents = [
          self.packages.${system}.jdk_musl_minimal
        ];
      };
      clojure = pkgs.callPackage ./clojure.nix {
        inherit (self.packages.${system}) jdk ant;
      };
      sbcl = pkgs.callPackage ./sbcl.nix { fat = false; };
      sbclFat = pkgs.callPackage ./sbcl.nix {
        inherit (self.packages.${system}) sqlite;
        inherit (pkgs) libuv;
        fat = true;
      };
      sbclMusl = pkgs.callPackage ./sbcl-musl.nix {
        inherit (self.packages.${system}) abcl;
      };
      sbcl_docker = pkgs.dockerTools.buildImage {
        name = "sbcl";
        tag = "latest";
        contents = [
          self.packages.${system}.sbcl
        ];
      };
      sbcl_musl_docker = pkgs.dockerTools.buildImage {
        name = "sbcl";
        tag = "musl";
        contents = [
          self.packages.${system}.sbclMusl
        ];
      };
      gcl = pkgs.callPackage ./gcl.nix {};
      emacs = pkgs.callPackage ./emacs.nix {
        inherit (self.packages.${system}) sqlite;
      };
      ant = pkgs.callPackage ./ant.nix {
        inherit (self.packages.${system}) jdk;
      };
      fd = pkgs.callPackage ./fd.nix {};
      sqlite = pkgs.callPackage ./sqlite.nix {};
      fossil = pkgs.callPackage ./fossil.nix {};
      clasp = pkgs.callPackage ./clasp.nix {};
      abcl = pkgs.callPackage ./abcl.nix {
        inherit (self.packages.${system}) jdk ant;
      };
      openssl_1_0_0 = pkgs.callPackage ./openssl_1_0_0.nix {};
      nix = pkgs.nixVersions.latest.overrideAttrs (prev: {
        patches = prev.patches or [] ++ [
          ./patches/nix-print-hash-mismatch-url.patch
          ./patches/nix-log-format-setting.patch
        ];
        doCheck = false;
        doInstallCheck = false;
      });
      libuv = pkgs.libuv.overrideAttrs (oa: {
        dontDisableStatic = true;
        doCheck = false;
      });
      mg = pkgs.callPackage ./mg.nix {};
      wpewebkit = pkgs.callPackage ./wpewebkit.nix {};
      wpebackend-fdo = pkgs.callPackage ./wpebackend-fdo.nix {};
      cog = pkgs.callPackage ./cog.nix {
        inherit (self.packages.${system}) wpewebkit wpebackend-fdo;
      };
      rlwrap = pkgs.rlwrap.overrideAttrs (oa: {
        patches = oa.patches or [] ++ [
          ./patches/rlwrap-work-in-emacs-term.patch
        ];
      });
      lem = pkgs.callPackage ./lem.nix {};
      adhocify = pkgs.callPackage ./adhocify.nix {};
      bash = pkgs.bashInteractive.overrideAttrs (a: {
        patches = a.patches or [] ++ [
          ./patches/bash-try-alias-completion-after-default.patch
        ];
      });
      i3 = pkgs.callPackage ./i3.nix {};
    });
  };
}
