{ fetchurl, nix, ... }:

let

  fossil-cc = fetchurl {
    url = "https://raw.githubusercontent.com/Uthar/nix/4fa87f6ebcdb655d22a779138c08431acb334d7d/src/libfetchers/fossil.cc";
    hash = "sha256-LLg6pdN01o7SWGOtcSMLOZX0VQA1m/bOovT8kQs7x40=";
  };

in nix.overrideAttrs (o: {
  postPatch = (o.postPatch or "") + ''
    cp -v ${fossil-cc} src/libfetchers
    substituteInPlace src/libmain/nix-main.pc.in --replace "-std=c++17" ""
    substituteInPlace src/libcmd/nix-cmd.pc.in --replace "-std=c++17" ""
    substituteInPlace src/libstore/nix-store.pc.in --replace "-std=c++17" ""
    substituteInPlace src/libexpr/nix-expr.pc.in --replace "-std=c++17" ""
    substituteInPlace Makefile --replace c++17 c++20
  '';
})
