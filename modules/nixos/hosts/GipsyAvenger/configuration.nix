{ pkgs, config, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nix.settings = {
    # Enable flakes and new 'nix' command
    experimental-features = "nix-command flakes";
    # Deduplicate and optimize nix store
    auto-optimise-store = true;
  };

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
  jovian.steamos.enableProductSerialAccess = false;
  jovian.steamos.enableVendorRadv = false;
  jovian.hardware.has.amd.gpu = true;
  jovian.decky-loader.enable = true;
  jovian.decky-loader.user = "fabiano";
  jovian.decky-loader.extraPackages = [
    pkgs.curl
    pkgs.dbus # For MusicControl plugin
    pkgs.python3
    pkgs.util-linux # Has 'rev' for MusicControl plugin
  ];
  jovian.decky-loader.extraPythonPackages = pythonPackages: [
    pkgs.python312Packages.hid
  ];

  # Got from: https://plugins.deckbrew.xyz/plugins
  jovian.decky-loader.plugins = {
    "SDH-CssLoader" = {
      src = pkgs.fetchzip {
        url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/1a1e8f4dded8494febe56df16429ef5bba1e5b8feb3fd989d5808fbef0d71350.zip";
        sha256 = "sha256-PoJNP6kqwTQphJxrgWq+uLCXjpcpAeJQ2Xu6d8UW6OY=";
        extension = "zip";
        stripRoot = true;
      };
    };
    "SDH-GameThemeMusic" = {
      src = pkgs.fetchzip {
        url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/c08110c6bf741ddbd2b31647123217ce816c93cf9e654b12d18696b979965bf6.zip";
        sha256 = "sha256-LnnofbFAGpZlZgl+lOHlWkiqDkgnANMoNK+GMh/8XHg=";
        extension = "zip";
        stripRoot = true;
      };
    };
    "protondb-decky" = {
      src = pkgs.fetchzip {
        url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/3894048d0d9b35342c85d9f50e9e5e4edc00b65e9dfe61d47ec5cf97bfd28da7.zip";
        sha256 = "sha256-iwoor0at8mYc6Ys+lh0GvhC/RaupMqvUe8G/sR0dNVQ=";
        extension = "zip";
        stripRoot = true;
      };
    };
    "SteamGridDB" = {
      src = pkgs.fetchzip {
        url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/b84f0a3f83b6e5d7cbc0ba9360bde33cfb400cf5f2a5d5c38f44a488e2c91a57.zip";
        sha256 = "sha256-0Hvmuu/Fm2mzk7nloq/azTTXsZOm/PGYoIL4bH6LFJE=";
        extension = "zip";
        stripRoot = true;
      };
    };
    "tab-master" = {
      src = pkgs.fetchzip {
        url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/002b951d41a14128f21169b17d33044710b9ab63b745276bf6ddc3af4c9983fc.zip";
        sha256 = "sha256-JXCn/JjadUP9nV7NvI+C5fKaL1zIw3BDPj+QwR2xBCc=";
        extension = "zip";
        stripRoot = true;
      };
    };
    "MusicControl" = {
      src = pkgs.fetchzip {
        url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/246b89fd653c60a735b1cc401d1b0937d5cb969eea9024561661ff741f081d62.zip";
        sha256 = "sha256-Ow0cvecOd/ZO7j5Xur3rRz+CAE5l/4pX3qGNcJ6wmF4=";
        extension = "zip";
        stripRoot = true;
      };
    };
    "Emuchievements" = {
      src = pkgs.fetchzip {
        url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/d9d43e9d0720615d109746a658fbbfd4b0d69e69b7444310e25ad62e415f7980.zip";
        sha256 = "sha256-28uGij7iqBEFvyzKAnuHXY5MRqfBs3ica0ckqXeYaBI=";
        extension = "zip";
        stripRoot = true;
      };
    };
  };

  programs.steam = {
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
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

  environment.systemPackages = [
    pkgs.appimage-run
    pkgs.vim
    pkgs.wget
    pkgs.python3
    pkgs.inputplumber
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
