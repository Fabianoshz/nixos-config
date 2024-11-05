{ pkgs, lib, ... }:
{
  nixpkgs.overlays = [
    (self: prev: {
      waydroid-exec = (pkgs.callPackage ../pkgs/waydroid-exec/default.nix {});
    })
  ];

  environment.systemPackages = [
    pkgs.waydroid-exec
    pkgs.weston
    pkgs.wl-clipboard
  ];

  system.activationScripts.addWaydroidKeylayout = lib.stringAfter [ "var" ] ''
    mkdir -p /var/lib/waydroid/overlay/system/usr/keylayout

    cp -fa ${./Vendor_28de_Product_11ff.kl} /var/lib/waydroid/overlay/system/usr/keylayout/Vendor_28de_Product_11ff.kl
  '';

  # This doesn't work
  # services.udev.packages = [
  #   (pkgs.writeTextFile {
  #     name = "steam-input-waydroid";
  #     text = ''ACTION=="add", SUBSYSTEM=="input", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="11ff", RUN+="${pkgs.coreutils}/bin/echo test > /tmp/test.log"'';
  #     destination = "/etc/udev/rules.d/40-steam-input-waydroid.rules";
  #   })
  #   (pkgs.writeTextFile {
  #     name = "steam-input-waydroid-1";
  #     text = ''ACTION=="add", SUBSYSTEM=="input", RUN+="${pkgs.coreutils}/bin/echo test > /tmp/test.log"'';
  #     destination = "/etc/udev/rules.d/40-steam-input-waydroid-1.rules";
  #   })
  # ];

  # services.udev.extraRules = ''
  #   ACTION=="add", SUBSYSTEM=="input", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="11ff", RUN+="${pkgs.coreutils}/bin/echo '%E{DEVNAME}' > /tmp/test.log"
  # '';
  # ACTION=="add", SUBSYSTEM=="input", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="11ff", RUN+="${pkgs.waydroid-exec}/bin/fix-controller '%E{DEVNAME}'"
}
