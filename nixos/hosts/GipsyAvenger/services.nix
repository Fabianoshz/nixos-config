{
  services = {
    inputplumber.enable = true;

    openssh.enable = true;
    desktopManager.plasma6.enable = true;

    pipewire = {
      enable = true;
      pulse.enable = true;
    };

    udev.extraRules = ''
      # Flydigi 2.4 GHz / Wired
      KERNEL=="hidraw*", ATTRS{idVendor}=="04b4", MODE="0660", TAG+="uaccess"
    '';
  };
}
