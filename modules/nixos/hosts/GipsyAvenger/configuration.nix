{ pkgs, config, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./jovian.nix

    ../../optional/decky-loader.nix
    ../../optional/inputplumber.nix
    ../../optional/waydroid/default.nix
  ];

  nix.settings = {
    # Enable flakes and new 'nix' command
    experimental-features = "nix-command flakes";
    # Deduplicate and optimize nix store
    auto-optimise-store = true;
  };

  nixpkgs.overlays = [
    (self: prev: {
      gamescope = prev.gamescope.overrideAttrs (oldAttrs: {
        patches = [./overlays/gamescope/fix-720p.patch] ++ oldAttrs.patches;
      });
    })
    (self: prev: {
      gamescope-session = prev.gamescope-session.overrideAttrs (oldAttrs: {
        patches = [./overlays/gamescope-session/fix-resolution.patch] ++ oldAttrs.patches;
      });
    })
    (self: prev: {
      xdg-desktop-portal-kde = prev.xdg-desktop-portal-kde.overrideAttrs (oldAttrs: {
        patches = [./overlays/xdg-desktop-portal-kde/allow-unattended.patch];
      });
    })
  ];

  programs.steam = {
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  networking.hostName = "GipsyAvenger";

  boot.plymouth.enable = true;
  boot.loader.grub.timeoutStyle = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;
  boot.kernelParams = ["quiet" "rd.systemd.show_status=false" "rd.udev.log_level=3" "udev.log_priority=3"];
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.initrd.systemd.enable = true;
  boot.kernelModules = [ "xpad" ];
  boot.extraModulePackages = [
    (config.boot.kernelPackages.callPackage ../../optional/pkgs/xpad/xpad.nix {})
  ];

  systemd.watchdog.rebootTime = "0";

  virtualisation.waydroid.enable = true;

  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
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

  services.inputplumber.enable = true;
  services.inputplumber.package = (pkgs.callPackage ../../optional/pkgs/inputplumber/default.nix {});

  services.openssh.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  users.users.fabiano = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICQgkNn6Nfr9LKJApkJzDvqaQMB8Lv/ynt9b1Vr1nwR"
    ];
    # shell = pkgs.zsh;
  };

  environment.systemPackages = [
    pkgs.appimage-run
    pkgs.kdePackages.xdg-desktop-portal-kde
    pkgs.python3
    pkgs.vim
    pkgs.wget
  ];

  environment.plasma6.excludePackages = with pkgs.libsForQt5; [
    elisa
    oxygen
    khelpcenter
    plasma-browser-integration
    print-manager
  ];

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [
      { from = 1714; to = 1764; } # KDE Connect
      { from = 3389; to = 3389; } # RDP
      { from = 21027; to = 21027; } # Syncthing
      { from = 22000; to = 22000; } # Syncthing
    ];
    allowedUDPPortRanges = [
      { from = 1714; to = 1764; } # KDE Connect
      { from = 21027; to = 21027; } # Syncthing
      { from = 22000; to = 22000; } # Syncthing
    ];
  };

  system.autoUpgrade = {
    enable = true;
    flags = [
      "--update-input"
      "nixpkgs"
      "-L" # print build logs
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  system.stateVersion = "24.11";
}
