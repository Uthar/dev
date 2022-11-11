{

  description = "Development environment";

  inputs.nixpkgs.url = "nixpkgs";
  inputs.nix.url = "nix/2.11.1";

  outputs = { self, flake-utils, nixpkgs, nix }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.outputs.legacyPackages.${system};
      pkgsMusl = nixpkgs.outputs.legacyPackages.${system}.pkgsMusl;
      nix-pkg = nix.packages.${system}.default;
    in {
      packages = rec {
        jdk = pkgs.jdk17;
        clojure = pkgs.callPackage ./clojure.nix { inherit jdk ant; };
        ecl = pkgs.callPackage ./ecl.nix {};
        sbcl = pkgs.callPackage ./sbcl.nix {};
        sbclStatic = pkgsMusl.callPackage ./sbcl.nix {};
        emacs = pkgs.callPackage ./emacs.nix { inherit sqlite; };
        ant = pkgs.callPackage ./ant.nix { inherit jdk; };
        fd = pkgs.callPackage ./fd.nix {};
        sqlite = pkgs.callPackage ./sqlite.nix {};
        fossil = pkgs.callPackage ./fossil.nix { inherit sqlite; };
        clasp = pkgs.callPackage ./clasp.nix {};
        abcl = pkgs.callPackage ./abcl.nix { inherit jdk ant; };
        openssl_1_0_0 = pkgs.callPackage ./openssl_1_0_0.nix {};
        nix = pkgs.callPackage ./nix.nix { nix = nix-pkg; };
        deps = pkgs.callPackage ./deps.nix { inherit jdk clojure; };
        cmucl = pkgs.callPackage ./cmucl.nix { };
      };
    });

}
  
