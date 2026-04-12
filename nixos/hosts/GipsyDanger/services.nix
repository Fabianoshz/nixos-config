{ pkgs, ... }:
{
  services = {
    # KDE
    desktopManager.plasma6.enable = true;
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
    displayManager.defaultSession = "plasma";

    # Enable the OpenSSH daemon.
    openssh.enable = true;
    xserver.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    xserver.excludePackages = [
      pkgs.xterm
    ];
  };

}
