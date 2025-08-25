{ pkgs, ... }:
{
  services = {
    # KDE
    desktopManager.plasma6.enable = true;
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
    displayManager.defaultSession = "plasma";

    # Disable gnome stuff
    xserver.displayManager.gdm.enable = false;
    xserver.displayManager.gdm.wayland = false;
    xserver.desktopManager.gnome.enable = false;

    # Enable the OpenSSH daemon.
    openssh.enable = true;
    xserver.enable = true;

    clamav = {
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

    udev.extraRules = ''
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0955", ATTRS{idProduct}=="7321", GROUP="plugdev"
      SUBSYSTEM=="usbmon", GROUP="wireshark", MODE="0640"
    '';
  };

}
