{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./environment.nix
    ./jovian.nix
    ./programs.nix
    ./services.nix
    ./virtualisation.nix

    ../../optional/decky-loader/default.nix
    ../../optional/waydroid/default.nix
    ../../optional/inputplumber/inputplumber.nix
  ];

  systemd.watchdog.rebootTime = "0";

  time.timeZone = "America/Sao_Paulo";

  fileSystems = {
    "/mnt/Games" = {
      device = "/dev/disk/by-uuid/6f0a07d5-46a4-4157-a57e-bd414e518baf";
      fsType = "ext4";
      options = [
        "nofail"
        "users"
        "defaults"
        "exec"
        "auto"
      ];
    };
  };

  users = {
    users.fabiano = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICQgkNn6Nfr9LKJApkJzDvqaQMB8Lv/ynt9b1Vr1nwR"
      ];
      shell = pkgs.zsh;
    };
  };

  fonts.packages = [ 
    pkgs.meslo-lgs-nf
  ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

  networking = {
    hostName = "GipsyAvenger";
    networkmanager.enable = true;  # Easiest to use and most distros use this by default.

    firewall = {
      enable = true;
      allowedTCPPortRanges = [
        { from = 1714; to = 1764; } # KDE Connect
        { from = 3389; to = 3389; } # RDP
        { from = 8384; to = 8384; } # Syncthing web
        { from = 21027; to = 21027; } # Syncthing
        { from = 22000; to = 22000; } # Syncthing
      ];
      allowedUDPPortRanges = [
        { from = 1714; to = 1764; } # KDE Connect
        { from = 21027; to = 21027; } # Syncthing
        { from = 22000; to = 22000; } # Syncthing
      ];
    };
  };

  boot = {
    plymouth.enable = true;
    loader.grub.timeoutStyle = false;
    loader.systemd-boot.enable = true;
    loader.systemd-boot.editor = false;
    loader.efi.canTouchEfiVariables = true;
    loader.timeout = 0;
    kernelParams = ["quiet" "rd.systemd.show_status=false" "rd.udev.log_level=3" "udev.log_priority=3"];
    consoleLogLevel = 0;
    initrd.verbose = false;
    initrd.systemd.enable = true;
    kernelModules = [ "xpad" ];
    extraModulePackages = [
      (config.boot.kernelPackages.callPackage ../../../pkgs/xpad/xpad.nix {})
    ];
  };

  system = {
    stateVersion = "24.11";

    autoUpgrade = {
      enable = true;
      flags = [
        "--update-input"
        "nixpkgs"
        "-L" # print build logs
      ];
      dates = "02:00";
      randomizedDelaySec = "45min";
    };
  };

  nix = {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
    };

    optimise.automatic = true;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}
