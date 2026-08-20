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

      # Wake from suspend by turning the game controller on.
      #
      # The 2.4GHz controller dongle can NOT remote-wake on a button press
      # (its firmware doesn't assert a USB resume while the bus is suspended,
      # verified by testing). But powering the controller on re-enumerates the
      # dongle, and that USB *connect* event wakes the machine.
      #
      # Arming wake-on-connect on the USB hubs (and root hubs) makes this work
      # regardless of which port/hub the dongle lands on (it moves around due
      # to the RJ45 USB extenders) and from a fresh boot. bDeviceClass 09 = hub.
      ACTION=="add", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="09", ATTR{power/wakeup}="enabled"
    '';
  };
}
