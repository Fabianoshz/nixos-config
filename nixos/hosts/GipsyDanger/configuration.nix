{ pkgs, lib, ... }:
{
  imports = [
    ./environment.nix
    ./hardware-configuration.nix
    ./programs.nix
    ./services.nix
    ./virtualisation.nix
  ];

  # Mount NFS
  fileSystems."/mnt/default/fabiano" = {
    device = "truenas.in.gambiarra.net:/mnt/default-2/fabiano";
    fsType = "nfs";
    options = [ "nfsvers=4.2" "noauto" ];
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
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICQgkNn6Nfr9LKJApkJzDvqaQMB8Lv/ynt9b1Vr1nwR"
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
    kernelParams = ["quiet" "rd.systemd.show_status=false" "rd.udev.log_level=3" "udev.log_priority=3"];
    consoleLogLevel = 0;
    initrd.verbose = false;
    initrd.systemd.enable = true;
    supportedFilesystems = [ "nfs" ];
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

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-unwrapped"
  ];

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
