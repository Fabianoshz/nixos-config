{ config, pkgs, lib, ... }:
with lib;
let
  general = builtins.fromJSON (builtins.readFile ../../../sensitive/general.json);
in
{
  imports = [
    ./environment.nix
    ./hardware-configuration.nix
    ./jovian.nix
    ./programs.nix
    ./services.nix
    ./virtualisation.nix

    ../../optional/decky-loader/default.nix
    ../../optional/waydroid/default.nix
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

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_NUMERIC = "pt_BR.UTF-8";
      LC_TIME = "pt_BR.UTF-8";
      LC_MONETARY = "pt_BR.UTF-8";
      LC_PAPER = "pt_BR.UTF-8";
      LC_NAME = "pt_BR.UTF-8";
      LC_ADDRESS = "pt_BR.UTF-8";
      LC_TELEPHONE = "pt_BR.UTF-8";
      LC_MEASUREMENT = "pt_BR.UTF-8";
      LC_IDENTIFICATION = "pt_BR.UTF-8";
      LC_TYPE = "pt_BR.UTF-8";
    };
  };

  users = {
    users.fabiano = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
      ];
      openssh.authorizedKeys.keys = [
        general.ssh.general
      ];
      shell = pkgs.zsh;
    };
  };

  fonts.packages = [
    pkgs.meslo-lgs-nf
  ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

  networking = {
    hostName = "GipsyAvenger";
    networkmanager.enable = true; # Easiest to use and most distros use this by default.

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
    consoleLogLevel = 0;
    initrd.verbose = false;
    initrd.systemd.enable = true;

    kernelParams = [ "quiet" "rd.systemd.show_status=false" "rd.udev.log_level=3" "udev.log_priority=3" "hid_nintendo" "hid_playstation" ];
  };

  hardware = {
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
  };

  system = {
    stateVersion = "25.05";

    autoUpgrade = {
      enable = true;
      flags = [
        "--update-input"
        "nixpkgs"
        "--commit-lock-file"
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
