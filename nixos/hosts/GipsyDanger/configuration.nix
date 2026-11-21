{ pkgs, lib, inputs, ... }:
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

  systemd.settings.Manager.RebootWatchdogSec = "0";

  # Wait for DNS to be ready before mounting NFS
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

  # Mount NFS with automount to avoid boot-time DNS issues on WiFi
  fileSystems = {
    "/mnt/default/fabiano" = {
      device = "truenas.${general.internal_domain}:/mnt/default-2/fabiano";
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

  time.timeZone = "America/Sao_Paulo";

  security.rtkit.enable = true;

  users = {
    users.fabiano = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "libvirtd"
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

  networking = {
    # Configure networking
    hostName = "GipsyDanger";
    networkmanager.enable = true;

    interfaces.enp7s0.wakeOnLan.enable = true; # Wake-on-LAN (magic packet).

    firewall = {
      enable = true;
      allowedTCPPortRanges = [
        { from = 12315; to = 12315; } # Grayjay
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
    plymouth.enable = true;
    loader.systemd-boot.enable = true;
    loader.systemd-boot.editor = false;
    loader.systemd-boot.configurationLimit = 10;
    loader.efi.canTouchEfiVariables = true;
    loader.timeout = 0;
    kernelParams = [ "quiet" "rd.systemd.show_status=false" "rd.udev.log_level=3" "udev.log_priority=3" ];
    consoleLogLevel = 0;
    initrd.verbose = false;
    initrd.systemd.enable = true;
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  system = {
    stateVersion = "25.05";
  };

  nixpkgs = {
    config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "claude-code"
      "discord"
      "grayjay"
      "obsidian"
      "steam"
      "steam-original"
      "steam-unwrapped"
    ];
  };

  nix = {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "fabiano" ];
      use-xdg-base-directories = true;
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
    };
  };
}
