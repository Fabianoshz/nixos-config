{ pkgs, ... }:
{
  # For discord
  flatpak.enable = true;
  flatpak.uninstallUnmanaged = true;

  inputplumber.enable = true;
  inputplumber.package = (pkgs.callPackage ../../pkgs/inputplumber/default.nix {});

  openssh.enable = true;
  desktopManager.plasma6.enable = true;
  pipewire = {
    enable = true;
    pulse.enable = true;
  };
}