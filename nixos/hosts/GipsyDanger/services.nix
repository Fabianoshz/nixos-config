{ pkgs, ... }:
{
  services = {
    # KDE
    desktopManager.plasma6.enable = true;
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
    displayManager.defaultSession = "plasma";

    # Disable gnome stuff
    displayManager.gdm.enable = false;
    displayManager.gdm.wayland = false;
    desktopManager.gnome.enable = false;

    # Enable the OpenSSH daemon.
    openssh.enable = true;
    xserver.enable = true;

    clamav = {
      daemon.enable = true;
      scanner.enable = true;
      updater.enable = true;
    };

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
