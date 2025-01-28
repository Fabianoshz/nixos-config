{ pkgs, ... }:
{
  services = {
    # For discord
    flatpak.enable = true;
    flatpak.uninstallUnmanaged = true;

    inputplumber.enable = true;

    openssh.enable = true;
    desktopManager.plasma6.enable = true;
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
  };
}
