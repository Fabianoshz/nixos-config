{ config, pkgs, lib, inputs, ... }:
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
    ./sunshine.nix

    ../../optional/decky-loader/default.nix
  ];

  systemd.settings.Manager.RebootWatchdogSec = "0";

  systemd.services."drkonqi-coredump-processor@".enable = false;
  systemd.user.sockets.drkonqi-coredump-launcher.enable = false;

  home-manager.startAsUserService = true;

  systemd.services.wait-for-dns = {
    description = "Wait for DNS resolution to be available";
    after = [ "NetworkManager.service" "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      if ${pkgs.dnsutils}/bin/dig +time=1 +tries=5 . NS >/dev/null 2>&1; then
        echo "DNS resolution successful"
      else
        echo "DNS resolution failed, continuing anyway"
      fi
    '';
  };

  time.timeZone = "America/Sao_Paulo";

  security.rtkit.enable = true;
  security.sudo.wheelNeedsPassword = false;

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
    "/mnt/default/common" = {
      device = "truenas.${general.internal_domain}:/mnt/default-2/common";
      fsType = "nfs";
      options = [
        "x-systemd.automount" # Mount on-demand instead of at boot
        "x-systemd.after=wait-for-dns.service" # Wait for DNS to be ready
        "x-systemd.idle-timeout=600" # Unmount after 10 minutes of inactivity
        "nfsvers=4.2"
        "_netdev"
        "nofail"
        "soft" # Use soft mounts to prevent indefinite hangs
        "timeo=30" # 3 second timeout (30 deciseconds)
        "retrans=2" # Retry 2 times before giving up
        "nordirplus" # Disable READDIRPLUS for better compatibility
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
      LC_CTYPE = "pt_BR.UTF-8";
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
    pkgs.nerd-fonts.jetbrains-mono
  ];

  networking = {
    hostName = "GipsyAvenger";
    networkmanager.enable = true; # Easiest to use and most distros use this by default.

    interfaces.enp8s0.wakeOnLan.enable = true; # Wake-on-LAN (magic packet).

    firewall = {
      enable = true;
      allowedTCPPortRanges = [
        { from = 3389; to = 3389; } # RDP
        { from = 8384; to = 8384; } # Syncthing web
        { from = 22000; to = 22000; } # Syncthing
      ];
      allowedUDPPortRanges = [
        { from = 21027; to = 21027; } # Syncthing
        { from = 22000; to = 22000; } # Syncthing
      ];
    };
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  boot = {
    kernel.sysctl."vm.swappiness" = 180;
    # kernelPackages = pkgs.linuxPackages_jovian;
    kernelPackages = pkgs.linuxPackages_latest;
    plymouth.enable = true;

    loader.systemd-boot.enable = true;
    loader.systemd-boot.editor = true;
    loader.systemd-boot.configurationLimit = 10;
    loader.efi.canTouchEfiVariables = true;
    loader.timeout = 0;
    consoleLogLevel = 0;

    kernelParams = [
      "quiet"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"

      # The root NVMe wedges after resume from S3 (kernel flags it "simple
      # suspend", invalid SUBNQN); anything touching disk then blocks forever.
      "nvme.noacpi=1" # Ignore the ACPI hint, use a normal NVMe suspend/resume.
      "nvme_core.default_ps_max_latency_us=0" # Disable APST deep power states.
    ];
  };

  hardware = {
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
  };

  system = {
    stateVersion = "25.11";
  };

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "discord"
        "discord-unwrapped"
        "grayjay"
        "grayjay-frontend"
        "grayjay-libcurlshim"
        "libretro-fbneo"
        "libretro-genesis-plus-gx"
        "libretro-snes9x"
        "steam"
        "steam-jupiter-original"
        "steam-jupiter-unwrapped"
        "steam-original"
        "steam-run"
        "steam-unwrapped"
        "steamdeck-hw-theme"
        "symphony-recomp"
      ];
    };

    overlays = [
      (final: prev: {
        amethyst-mod-manager = prev.amethyst-mod-manager.overrideAttrs (old: {
          amethyst_filegraph = old.amethyst_filegraph.overrideAttrs (o: {
            buildInputs = (o.buildInputs or [ ]) ++ [ final.sqlite ];
          });
        });
      })
      (final: prev: {
        libretro = prev.libretro // {
          pcsx2 = prev.libretro.pcsx2.overrideAttrs (old: {
            version = "0-unstable-2026-10-09";
            src = prev.fetchFromGitHub {
              owner = "libretro";
              repo = "ps2";
              rev = "5335635718de126120466ca811bac309cdc06f53";
              hash = "sha256-IoOOX5zU9PfE9z1wu/WYlwC+g2p2FxgE2lMCPAKpJcM=";
              fetchSubmodules = true;
            };
            postPatch = (old.postPatch or "") + ''
              substituteInPlace pcsx2/Pcsx2Config.cpp \
                --replace-fail 'LoadTextureReplacements = false;' 'LoadTextureReplacements = true;'
            '';
          });
        };
      })
      (final: prev:
        let
          patchSession = pkg: (pkg.override {
            steam = config.programs.steam.package;
          }).overrideAttrs (old: {
            # Single scanout plane so Sunshine's KMS capture sees the whole frame.
            postPatch = old.postPatch + ''
              substituteInPlace gamescope-session \
                --replace-fail '--generate-drm-mode fixed' '--disable-layers --generate-drm-mode fixed'
            '';
          });
        in
        {
          gamescope-session = patchSession prev.gamescope-session;
          # Jovian's session uses its own scope's copy.
          jovianPackages = prev.jovianPackages.overrideScope (_: p: {
            gamescope-session = patchSession p.gamescope-session;
          });
        })
    ];
  };

  nix = {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "fabiano" ];
    };

    optimise.automatic = true;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}
