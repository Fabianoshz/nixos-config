{ pkgs, ... }:
{
  services = {
    inputplumber.enable = true;

    openssh.enable = true;
    desktopManager.plasma6.enable = true;
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
  };
}
