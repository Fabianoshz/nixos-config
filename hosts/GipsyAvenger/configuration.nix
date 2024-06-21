{ pkgs, config, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./configs/syncthing.nix
  ];

  nixpkgs.overlays = [
    (final: prev: {
      gamescope = prev.gamescope.overrideAttrs (previousAttrs: {
        patches = previousAttrs.patches ++ [
          /etc/nixos/hosts/GipsyAvenger/patches/gamescope/fix-720p.patch
        ];
      });
    })
  ];

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "steam"
        "steam-run"
        "steamdeck-hw-theme"
        "steam-jupiter-original"
      ];
    };
  };

  jovian.steam.enable = true;
  jovian.steam.autoStart = true;
  jovian.steam.user = "fabiano";
  jovian.steam.desktopSession = "plasma";

  programs.steam = {
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  ## Enable flakes
  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    # Inspired by https://github.com/Misterio77/nix-starter-configs/blob/972935c1b35d8b92476e26b0e63a044d191d49c3/standard/nixos/configuration.nix
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
    };
  };

  networking.hostName = "GipsyAvenger";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
  ];

  environment.plasma6.excludePackages = with pkgs.libsForQt5; [
    elisa
    oxygen
    khelpcenter
    plasma-browser-integration
    print-manager
  ];

  programs.steam = {
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [
      { from = 1714; to = 1764; } # KDE Connect
    ];
    allowedUDPPortRanges = [
      { from = 1714; to = 1764; } # KDE Connect
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

  system.stateVersion = "24.05";
}
