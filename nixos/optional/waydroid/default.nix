{ pkgs, lib, ... }:
{
  nixpkgs.overlays = [
    (self: prev: {
      waydroid-exec = (pkgs.callPackage ../../../pkgs/waydroid-exec/default.nix { });
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

  systemd.services.fix-waydroid-controller = {
    enable = true;
    description = "A service to fix the controller when waydroid is started";
    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash ${pkgs.waydroid-exec}/bin/fix-waydroid-controller";
    };
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.gawk pkgs.waydroid pkgs.gnugrep pkgs.coreutils pkgs.ps pkgs.sudo ];
  };

  security.sudo.extraRules = [
    {
      groups = [ "users" ];
      commands = [
        { command = "/run/current-system/sw/bin/tee -a /sys/devices/virtual/input/input*/event*/uevent"; options = [ "NOPASSWD" ]; }
      ];
    }
  ];
}
