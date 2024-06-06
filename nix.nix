{ nix, ... }:

nix.overrideAttrs (o: {
  patches = [
    ./patches/nix-print-hash-mismatch-url.patch
  ];
})
