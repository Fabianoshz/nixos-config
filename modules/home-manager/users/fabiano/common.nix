{ config, pkgs, pkgs-23-11, lib, inputs, ... }:
{
  home.stateVersion = "24.05";

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "spotify"
      ];
    };
  };

  home.packages = [
    pkgs.bash
    pkgs.dig
    pkgs.firefox-bin
    pkgs.git
    pkgs.htop
    pkgs.spotify
  ];
}