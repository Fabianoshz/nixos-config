{ pkgs, ... }:
{
  imports = [
     # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nix.settings = {
    # Enable flakes and new 'nix' command
    experimental-features = "nix-command flakes";
  };

  nix.optimise.automatic = true;

  # Mount NFS
  # fileSystems."/mnt/default/fabiano" = {
  #   device = "truenas.in.gambiarra.net:/mnt/default/fabiano";
  #   fsType = "nfs";
  #   options = [ "nfsvers=4.2" "x-systemd.automount" "noauto" ];
  # };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vulkan-loader
      vulkan-validation-layers
      vulkan-extension-layer
    ];
  };

  # Configure networking
  networking.hostName = "GipsyDanger";
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
  };

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
      "wireshark"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICQgkNn6Nfr9LKJApkJzDvqaQMB8Lv/ynt9b1Vr1nwR"
    ];
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    # home-manager
    docker-machine-kvm2
    git
    libusb1
    nordic
    vim
  ];

  environment.sessionVariables = rec {
    CUDA_CACHE_PATH = "$XDG_CACHE_HOME/nv";
    GTK_IM_MODULE   = "cedilla";
    QT_IM_MODULE    = "cedilla";
    SSH_AUTH_SOCK   = "$XDG_RUNTIME_DIR/ssh-agent";
    XCOMPOSECACHE   = "$XDG_CACHE_HOME/X11/xcompose";
    XDG_CACHE_HOME  = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME   = "$HOME/.local/share";
    XDG_STATE_HOME  = "$HOME/.local/state";
  };

  programs.zsh.enable = true;

  programs.dconf.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.xserver.enable = true;

  # KDE
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
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

  boot.kernelModules = [ "kvm-amd" ];

  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = false;
  virtualisation.podman.enable = true;
  virtualisation.waydroid.enable = false;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

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
      { from = 21027; to = 21027; } # Syncthing
      { from = 22000; to = 22000; } # Syncthing
    ];
    allowedUDPPortRanges = [
      { from = 1714; to = 1764; } # KDE Connect
      { from = 21027; to = 21027; } # Syncthing
      { from = 22000; to = 22000; } # Syncthing
    ];
  };

  networking.hosts = {
    "127.0.0.1" = [ "localhost" "GipsyDanger" ];
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0955", ATTRS{idProduct}=="7321", GROUP="plugdev"
    SUBSYSTEM=="usbmon", GROUP="wireshark", MODE="0640"
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

  system.stateVersion = "24.11";
}
