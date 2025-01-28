{
  programs = {
    zsh.enable = true;

    steam = {
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
    appimage = {
      enable = true;
      binfmt = true;
    };
  };
}
