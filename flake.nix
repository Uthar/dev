
{

  description = "Development environment";

  inputs.nixpkgs.url = "nixpkgs";
  inputs.nix.url = "nix/2.22.1";
  inputs.nix-clj.url = "github:uthar/nix-clj";

  outputs = { self, nixpkgs, nix, nix-clj }:
    let
      systems = ["x86_64-linux"];
    in {
      devShells = nixpkgs.lib.genAttrs systems (system: let
        pkgs = nixpkgs.outputs.legacyPackages.${system};
        sbcl' = pkgs.sbcl.withPackages (ps: with ps; [
          alexandria bordeaux-threads cl-cpus jzon
        ]);
      in {
        default = pkgs.mkShell {
          packages = [ sbcl' ];
        };
      });
      packages = nixpkgs.lib.genAttrs systems (system: let
        pkgs = nixpkgs.outputs.legacyPackages.${system};
        nix-pkg = nix.packages.${system}.default;
        cljpkgs = nix-clj.packages.${system};
        wpebackends = pkgs.callPackage ./wpebackends.nix {};
      in rec {
        jdk = pkgs.jdk17;
        jdk_minimal = pkgs.jdk17.override {
          headless = true;
          enableJavaFX = false;
          enableGnome2 = false;
        };
        jre_minimal = pkgs.jre_minimal.override {
          jdk = jdk_minimal;
        };
        jre_docker = pkgs.dockerTools.buildImage {
          name = "jre";
          tag = "latest";
          contents = [
            jre_minimal
          ];
        };
        jdk_musl = pkgs.pkgsMusl.jdk17.override {
          headless = true;
          enableJavaFX = false;
          enableGnome2 = false;
        };
        jdk_musl_minimal = pkgs.pkgsMusl.jre_minimal.override {
          jdk = jdk_musl;
        };
        jdk_musl_docker = pkgs.dockerTools.buildImage {
          name = "jre";
          tag = "musl";
          contents = [
            jdk_musl_minimal
          ];
        };
        clojure = pkgs.callPackage ./clojure.nix { inherit jdk ant; };
        cider = pkgs.callPackage ./cider.nix { inherit cljpkgs; };
        sbcl = pkgs.callPackage ./sbcl.nix { fat = false; };
        sbclFat = pkgs.callPackage ./sbcl.nix {
          inherit sqlite libuv;
          fat = true;
        };
        sbclMusl = pkgs.callPackage ./sbcl-musl.nix { inherit abcl; };
        sbcl_docker = pkgs.dockerTools.buildImage {
          name = "sbcl";
          tag = "latest";
          contents = [
            sbcl
          ];
        };
        sbcl_musl_docker = pkgs.dockerTools.buildImage {
          name = "sbcl";
          tag = "musl";
          contents = [
            sbclMusl
          ];
        };
        gcl = pkgs.callPackage ./gcl.nix {};
        emacs = pkgs.callPackage ./emacs.nix { inherit sqlite; };
        ant = pkgs.callPackage ./ant.nix { inherit jdk; };
        fd = pkgs.callPackage ./fd.nix {};
        sqlite = pkgs.callPackage ./sqlite.nix {};
        fossil = pkgs.callPackage ./fossil.nix { inherit sqlite; };
        clasp = pkgs.callPackage ./clasp.nix {};
        abcl = pkgs.callPackage ./abcl.nix { inherit jdk ant; };
        openssl_1_0_0 = pkgs.callPackage ./openssl_1_0_0.nix {};
        nix = pkgs.callPackage ./nix.nix { nix = nix-pkg; };
        libuv = pkgs.libuv.overrideAttrs (oa: {
          dontDisableStatic = true;
          doCheck = false;
        });
        mg = pkgs.callPackage ./mg.nix {};
        wpewebkit = pkgs.callPackage ./wpewebkit.nix {};
        wpebackend-fdo = wpebackends.fdo;
        cog = pkgs.callPackage ./cog.nix { inherit wpewebkit wpebackend-fdo; };
        rlwrap = pkgs.rlwrap.overrideAttrs (oa: {
          patches = oa.patches or [] ++ [
            ./patches/rlwrap-work-in-emacs-term.patch
          ];
        });
        lem = pkgs.callPackage ./lem.nix {};
      });
    };

}
