{ pkgs, lib, ... }:
{
  nixpkgs.overlays = [
    (self: prev: {
      waydroid-exec = (pkgs.callPackage ../pkgs/waydroid-exec/default.nix {});
    })
  ];

  security.sudo.extraRules = [
    { groups = [ "wheel" ]; commands = [ { command = "${pkgs.waydroid-exec}/bin/fix-controller"; options = [ "NOPASSWD" ]; } ]; }
    { groups = [ "wheel" ]; commands = [ { command = "/run/current-system/sw/bin/fix-controller"; options = [ "NOPASSWD" ]; } ]; }
  ]; 

  environment.systemPackages = [
    pkgs.wl-clipboard
    pkgs.waydroid-exec
    pkgs.cage
  ];

  system.activationScripts.addWaydroidKeylayout = lib.stringAfter [ "var" ] ''
    mkdir -p /var/lib/waydroid/overlay/system/usr/keylayout

    cp -fa ${./Vendor_28de_Product_11ff.kl} /var/lib/waydroid/overlay/system/usr/keylayout/Vendor_28de_Product_11ff.kl
  '';
}
