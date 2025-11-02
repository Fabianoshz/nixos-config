{ pkgs, lib, inputs, ... }:
with lib;
let
  general = builtins.fromJSON (builtins.readFile ../../../sensitive/general.json);
in
{
  imports = [
    ./environment.nix
    ./hardware-configuration.nix
    ./programs.nix
    ./services.nix
    ./virtualisation.nix
  ];

  # Mount NFS with non-blocking options to prevent Dolphin freezes
  fileSystems."/mnt/default/fabiano" = {
    device = "truenas.${general.internal_domain}:/mnt/default-2/fabiano";
    fsType = "nfs";
    options = [
      "nfsvers=4.2"
      "_netdev"
      "nofail"
      "soft" # Use soft mounts to prevent indefinite hangs
      "timeo=30" # 3 second timeout (30 deciseconds)
      "retrans=2" # Retry 2 times before giving up
      "bg" # Background mount if server unavailable
      "intr" # Allow interruption of NFS calls
      "rsize=32768" # Read buffer size
      "wsize=32768" # Write buffer size
      "nordirplus" # Disable READDIRPLUS for better compatibility
    ];
  };

  time.timeZone = "America/Sao_Paulo";

  security.rtkit.enable = true;

  users = {
    users.fabiano = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "libvirtd"
        "docker"
        "wireshark"
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

  networking = {
    # Configure networking
    hostName = "GipsyDanger";
    networkmanager.enable = true;

    firewall = {
      enable = true;
      allowedTCPPortRanges = [
        { from = 1714; to = 1764; } # KDE Connect
        { from = 12315; to = 12315; } # Grayjay
        { from = 21027; to = 21027; } # Syncthing
        { from = 22000; to = 22000; } # Syncthing
      ];
      allowedUDPPortRanges = [
        { from = 1714; to = 1764; } # KDE Connect
        { from = 21027; to = 21027; } # Syncthing
        { from = 22000; to = 22000; } # Syncthing
      ];
    };

    hosts = {
      "127.0.0.1" = [ "localhost" "GipsyDanger" ];
    };
  };

  boot = {
    plymouth.enable = true;
    loader.grub.timeoutStyle = false;
    loader.systemd-boot.enable = true;
    loader.systemd-boot.editor = false;
    loader.efi.canTouchEfiVariables = true;
    loader.timeout = 0;
    kernelParams = [ "quiet" "rd.systemd.show_status=false" "rd.udev.log_level=3" "udev.log_priority=3" ];
    consoleLogLevel = 0;
    initrd.verbose = false;
    initrd.systemd.enable = true;
    supportedFilesystems = [ "nfs" ];
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

  nixpkgs = {
    config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "discord"
      "obsidian"
      "steam"
      "steam-original"
      "steam-unwrapped"
    ];
    overlays = [
      (final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          inherit (prev) system;
          config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
            "claude-code"
            "grayjay"
          ];
        };
      })
    ];
  };

  nix = {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      trusted-users = [ "fabiano" ];
    };

    optimise.automatic = true;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  hardware = {
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;

    # Enable OpenGL
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        vulkan-loader
        vulkan-validation-layers
        vulkan-extension-layer
      ];
    };
  };
}
