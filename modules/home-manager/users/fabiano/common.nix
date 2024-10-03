{ pkgs, ... }:
{
  home.packages = [
    pkgs.bash
    pkgs.dig
    pkgs.git
    pkgs.htop
    pkgs.spotify
    pkgs.whois
  ];
}
