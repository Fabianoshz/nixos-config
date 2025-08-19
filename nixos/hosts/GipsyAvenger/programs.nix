{ pkgs, ... }:
{
  programs = {
    zsh.enable = true;

    steam = {
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };
    appimage = {
      enable = true;
      binfmt = true;
    };
  };
}
