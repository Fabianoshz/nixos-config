# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, lib, config, pkgs, ... }: 
{
  imports = [
     # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./configs/syncthing.nix
  ];

  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nix.nixPath = ["/etc/nix/path"];
  environment.etc =
    lib.mapAttrs'
    (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    })
    config.nix.registry;

  nix.settings = {
    # Enable flakes and new 'nix' command
    experimental-features = "nix-command flakes";
    # Deduplicate and optimize nix store
    auto-optimise-store = true;
  };

  # Mount NFS
  # fileSystems."/mnt/default/fabiano" = {
  #   device = "truenas.in.gambiarra.net:/mnt/default/fabiano";
  #   fsType = "nfs";
  #   options = [ "x-systemd.automount" "noauto" ];
  #   # options = [ "nfsvers=4.2" ];
  # };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages = with pkgs; [
    rocm-opencl-icd
    rocm-opencl-runtime
  ];

  # Configure networking
  networking.hostName = "GipsyDanger";
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.fabiano = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "libvirtd"
      "docker"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDga6t/7DhFnW7VrfbuOkpg98+7lwtWDIkpJe3AI89pDEwvYXKGp9sTOpZLk/dtW67+tb48sDOZsqtJoND3JdM/IY4MMPW7bjnbIXi3urh8aMvcEEz7HxUvQwMo3Zk53xcfZvQ6oXJa41V/RZHiXVo6WoPb4ZpbHH+XTWl0VoAz7L7LGGqhYzSqqmyGh/3s7FCKO9i4Gho+6sqy2VKkf935/8oURJFmx3D6h+JGiLV0Y5Jm4emeRTVO9YdauLaC361DNl6/WrX6SYGgrsXwQuWkIFfjrMh0qI6Hk33GQ/WM7jQbZi9phUMHH/Xvcnuz9t80XoKodWOI3xaRml4Ngnze8j73AgKqqU4aq+vyfbSUPNUIEytqJQVZ7mwpiIm2R/l+OA6Gb7GYfdrwrCgRJDYHEa8fi6Qtm3DMViRPWz/k8Zo41p531bYURJS+CFMod+OKtkSzFXURwKuLnqNKkiZQSaXQiUmclfXxGG96z78yNaAYpnL2l1n6c1hHYgtKZfM="
    ];
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    docker-machine-kvm2
    # home-manager
    git
    vim
    ntfs3g
    nordic
    libusb
  ];

  environment.sessionVariables = rec {
    XDG_CACHE_HOME  = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME   = "$HOME/.local/share";
    XDG_STATE_HOME  = "$HOME/.local/state";
    CUDA_CACHE_PATH = "$XDG_CACHE_HOME/nv";
    XCOMPOSECACHE   = "$XDG_CACHE_HOME/X11/xcompose";
    GTK_IM_MODULE   = "cedilla";
    QT_IM_MODULE    = "cedilla";
    SSH_AUTH_SOCK   = "$XDG_RUNTIME_DIR/ssh-agent";
  };

  programs.zsh.enable = true;

  programs.dconf.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.xserver.enable = true;

  # KDE
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "plasma";

  # Gnome
  services.xserver.displayManager.gdm.enable = false;
  services.xserver.displayManager.gdm.wayland = false;
  services.xserver.desktopManager.gnome.enable = false;

  services.xserver.excludePackages = [
    pkgs.xterm
  ];

  # Remove KDE packages
  environment.plasma6.excludePackages = with pkgs.libsForQt5; [
    elisa
    oxygen
    khelpcenter
    plasma-browser-integration
    print-manager
  ];

  environment.shells = with pkgs; [ zsh ];

  boot.kernelModules = [ "kvm-amd" "xpad" ];

  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.docker.enable = true;
  # virtualisation.docker.rootless = {
  #   enable = true;
  #   setSocketVariable = true;
  # };
  virtualisation.podman.enable = true;
  virtualisation.waydroid.enable = false;

  nixpkgs.config.allowUnfree = true;
  programs.steam = {
    enable = true;
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

  networking.hosts = {
    "127.0.0.1" = [ "localhost" "GipsyDanger" ];
  };

  services.udev.extraRules = ''
    ATTRS{idVendor}=="2dc8", ATTRS{idProduct}=="3106", RUN+="${pkgs.stdenv.shell} -c 'echo 2dc8 3106 > /sys/bus/usb/drivers/xpad/new_id'"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0955", ATTRS{idProduct}=="7321", GROUP="plugdev"
  '';

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

  system.stateVersion = "24.05"; # Did you read the comment?
}
