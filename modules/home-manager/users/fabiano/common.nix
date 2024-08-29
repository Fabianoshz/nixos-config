{ config, pkgs, pkgs-23-11, lib, inputs, ... }:
{
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