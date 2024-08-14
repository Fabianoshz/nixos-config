{ config, pkgs, pkgs-23-11, lib, inputs, ... }:
{
  home.stateVersion = "24.05";

  home.packages = [
    pkgs.bash
    pkgs.dig
    pkgs.firefox-bin
    pkgs.git
    pkgs.htop
    pkgs.spotify

    pkgs.whois
  ];
}