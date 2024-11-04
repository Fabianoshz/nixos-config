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

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="11ff", MODE="0666", TAG+="uaccess"
  '';
}
