let
#  nixpkgs = import <nixpkgs>;
  pkgs = import <nixpkgs> {
    config = {};
    overlays = [
      (import ./overlay.nix)
    ];
  };

in pkgs.dragino-lht65
