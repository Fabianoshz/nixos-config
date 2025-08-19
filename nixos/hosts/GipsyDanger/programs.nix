{
  programs = {
    zsh.enable = true;

    dconf.enable = true;

    appimage = {
      enable = true;
      binfmt = true;
    };

    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
  };
}
