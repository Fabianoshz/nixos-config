# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, ... }: 
{
  imports = [
     # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

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

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICQgkNn6Nfr9LKJApkJzDvqaQMB8Lv/ynt9b1Vr1nwR"
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

  services = {
    syncthing = {
      enable = true;
      user = "fabiano";
      configDir = "/home/fabiano/.config/syncthing";
      dataDir = "/home/fabiano/.config/syncthing/db";

      settings = {
        gui.theme = "default";

        options = {
          urAccepted = -1;
          globalAnnounceServers = ["https://syncthing-discosrv.gambiarra.net"];
          listenAddresses = [
            "quic://0.0.0.0:22000"
            "tcp://0.0.0.0:22000"
            "relay://syncthing-relaysrv.gambiarra.net:22067/?id=2UMOT3V-A523Q2O-HMCYV2Y-RV7GCXU-6G7HJ6J-FM4TXSX-JZCQOGF-MLHTLQY&networkTimeout=2m0s&pingInterval=1m0s&statusAddr=%3A22070"
          ];
        };

        devices = {
          "Syncthing Server" = { id = "5UA5VGL-USWXJUO-QQAYDXF-CQJ2ESN-AE36JZV-4GOCRIH-5I35HFQ-4O3PMAX"; addresses = [ "tcp://syncthing.gambiarra.net:22000" "relay://syncthing-relaysrv.gambiarra.net:22067/?id=2UMOT3V-A523Q2O-HMCYV2Y-RV7GCXU-6G7HJ6J-FM4TXSX-JZCQOGF-MLHTLQY&networkTimeout=2m0s&pingInterval=1m0s&statusAddr=%3A22070" ]; };
          "Odin" = { id = "ZGAPLG6-FXWLCHE-E2RMF3C-ZIYDVM2-HJDM5TO-NXDOMHW-KVFEGTM-CS2EGAK"; };
          "CrimsonTyphoon" = { id = "VT4BQGE-W2ENWSL-J7H2BDQ-D6ZCOME-G3WBEQR-P3XGIRG-T3D2ZOC-Y6FYPQI"; };
          "GipsyAvenger" = { id = "MXHBOLC-SRRHHTV-GPZFIOZ-Z4AVXRY-U2KLJE4-HDJTCCO-IVO66VU-XRWDKQR"; };
          "ChernoAlpha" = { id = "RBHIV3L-FYDEZIY-3KMQQR4-65CHAME-SF7SYDV-MH6JFUK-Y2DJPKT-IEYV2AZ"; };
          "CrimsonPhoenix" = { id = "K4XUFHC-5J53HLV-N3YNAPZ-ZZRSPJL-PHNR2P3-2CVGI2O-FIP6CPF-VXFFZQG"; };
          "MiyooMiniPlus" = { id = "QAHTB2L-BWCZ323-I52LZFC-OU3U3PH-ZUKGBHS-7T3X3YY-XRBCCYB-5CFEKAO"; };
        };

        folders = {
          "[Documents] Common" = {
            enable  = true;
            path    = "/home/fabiano/Documents/Common";
            devices = [ "CrimsonTyphoon" "ChernoAlpha" "Syncthing Server" "CrimsonPhoenix" ];
          };
          "[Documents] Passwords" = {
            enable  = true;
            path    = "/home/fabiano/Documents/Passwords";
            devices = [ "CrimsonTyphoon" "ChernoAlpha" "Syncthing Server" "CrimsonPhoenix" ];
          };
          "[Documents] Share" = {
            enable  = true;
            path    = "/home/fabiano/Documents/Share";
            devices = [ "CrimsonTyphoon" "ChernoAlpha" "Odin" "Syncthing Server" "CrimsonPhoenix" "GipsyAvenger" ];
          };
          "[Documents] Workspaces" = {
            enable  = true;
            path    = "/home/fabiano/Documents/Workspaces";
            devices = [ "Syncthing Server" "CrimsonPhoenix" ];
          };

          "[Games] Game Boy Roms" = {
            enable  = true;
            path    = "/home/fabiano/Games/Roms/gb";
            devices = [ "Odin" "ChernoAlpha" "MiyooMiniPlus" ];
          };
          "[Games] Game Boy Color Roms" = {
            enable  = true;
            path    = "/home/fabiano/Games/Roms/gbc";
            devices = [ "Odin" "ChernoAlpha" "MiyooMiniPlus" ];
          };
          "[Games] Game Boy Advanced Roms" = {
            enable  = true;
            path    = "/home/fabiano/Games/Roms/gba";
            devices = [ "Odin" "GipsyAvenger" "MiyooMiniPlus" ];
          };
          "[Games] Nintendo DS Roms" = {
            enable  = true;
            path    = "/home/fabiano/Games/Roms/nds";
            devices = [ "Odin" ];
          };
          "[Games] 3DS Roms" = {
            enable  = true;
            path    = "/home/fabiano/Games/Roms/3ds";
            devices = [ "Odin" ];
          };
          "[Games] Super Nintendo Roms" = {
            enable  = true;
            path    = "/home/fabiano/Games/Roms/snes";
            devices = [ "Odin" "CrimsonPhoenix" "GipsyAvenger" "MiyooMiniPlus" ];
          };
          "[Games] Nintendo 64 Roms" = {
            enable  = true;
            path    = "/home/fabiano/Games/Roms/n64";
            devices = [ "Odin" "GipsyAvenger" ];
          };
          "[Games] Game Cube Roms" = {
            enable  = true;
            path    = "/home/fabiano/Games/Roms/gc";
            devices = [ "Odin" "GipsyAvenger" ];
          };
          "[Games] Nintendo Wii Roms" = {
            enable  = true;
            path    = "/home/fabiano/Games/Roms/wii";
            devices = [ "Odin" "GipsyAvenger" ];
          };
          "[Games] Nintendo Switch Roms" = {
            enable  = true;
            path    = "/home/fabiano/Games/Roms/switch";
            devices = [ "ChernoAlpha" "GipsyAvenger" ];
          };
          "[Games] Playstation Roms" = {
            enable  = true;
            path    = "/home/fabiano/Games/Roms/psx";
            devices = [ "Odin" "CrimsonPhoenix" "GipsyAvenger" "MiyooMiniPlus" ];
          };
          "[Games] Playstation 2 Roms" = {
            enable  = true;
            path    = "/home/fabiano/Games/Roms/ps2";
            devices = [ "Odin" "CrimsonPhoenix" "GipsyAvenger" ];
          };
          "[Games] PSP Roms" = {
            enable  = true;
            path    = "/home/fabiano/Games/Roms/psp";
            devices = [ "Odin" "GipsyAvenger" ];
          };
          "[Games] Saturn Roms" = {
            enable  = true;
            path    = "/home/fabiano/Games/Roms/saturn";
            devices = [ "Odin" "GipsyAvenger" ];
          };
          "[Games] MAME Roms" = {
            enable  = true;
            path    = "/home/fabiano/Games/Roms/mame";
            devices = [ "Odin" "GipsyAvenger" ];
          };

          "[Games] PS2 Memory cards" = {
            enable  = true;
            path    = "/home/fabiano/Games/PS2 Memory cards";
            devices = [ "Odin" "Syncthing Server" "CrimsonPhoenix" "GipsyAvenger" ];
          };

          "[Games] Retroarch Saves" = {
            enable  = true;
            path    = "/home/fabiano/Games/Retroarch/Saves";
            devices = [ "Odin" "ChernoAlpha" "Syncthing Server" "CrimsonPhoenix" "GipsyAvenger" "MiyooMiniPlus" ];
            versioning = { 
              type = "simple"; 
              params = { 
                keep = "10";
              }; 
            };
          };

          "[Games] Retroarch States" = {
            enable  = true;
            path    = "/home/fabiano/Games/Retroarch/States";
            devices = [ "Odin" "ChernoAlpha" "Syncthing Server" "CrimsonPhoenix" "GipsyAvenger" "MiyooMiniPlus" ];
            versioning = { 
              type = "simple"; 
              params = { 
                keep = "10";
              }; 
            };
          };

          "[Games] Retroarch Runtime Logs" = {
            enable  = true;
            path    = "/home/fabiano/Games/Retroarch/Runtime logs";
            devices = [ "Odin" "ChernoAlpha" "Syncthing Server" "CrimsonPhoenix" "GipsyAvenger" "MiyooMiniPlus" ];
            versioning = { 
              type = "simple"; 
              params = { 
                keep = "10";
              }; 
            };
          };

          "[Games] Retroarch System" = {
            enable  = true;
            path    = "/home/fabiano/Games/Retroarch/System";
            devices = [ "Odin" "ChernoAlpha" "Syncthing Server" "CrimsonPhoenix" "GipsyAvenger" "MiyooMiniPlus" ];
            versioning = { 
              type = "simple"; 
              params = { 
                keep = "10";
              }; 
            };
          };

          "[Yuzu] Saves" = {
            enable  = true;
            path    = "/home/fabiano/.local/share/yuzu/nand/user/save";
            devices = [ "Syncthing Server" "GipsyAvenger" ];
          };
          "[Citra] SDMC" = {
            enable  = true;
            path    = "/home/fabiano/.local/share/citra-emu/sdmc";
            devices = [ "Odin" "Syncthing Server" ];
          };

          "[PCSX2] Cheats" = {
            enable  = true;
            path    = "/home/fabiano/.config/PCSX2/cheats";
            devices = [ "Syncthing Server" "GipsyAvenger" ];
          };
          "[PCSX2] States" = {
            enable  = true;
            path    = "/home/fabiano/.config/PCSX2/sstates";
            devices = [ "Syncthing Server" "GipsyAvenger" ];
          };
          "[PCSX2] Covers" = {
            enable  = true;
            path    = "/home/fabiano/.config/PCSX2/covers";
            devices = [ "Syncthing Server" "GipsyAvenger" ];
          };

          "[Saves] Diablo II Ressurected" = {
            enable  = true;
            path    = "/home/fabiano/.local/share/Steam/steamapps/compatdata/2202640766/pfx/drive_c/users/steamuser/Saved Games";
            devices = [ "Syncthing Server" "GipsyAvenger" ];
            versioning = { 
              type = "simple"; 
              params = { 
                keep = "10";
              }; 
            };
          };

          "[Saves] Dynasty Warriors 8" = {
            enable  = true;
            path    = "/home/fabiano/.steam/steam/steamapps/compatdata/278080/pfx/drive_c/users/steamuser/Documents/TecmoKoei/Dynasty Warriors 8/Savedata";
            devices = [ "Syncthing Server" "GipsyAvenger" ];
            versioning = { 
              type = "simple"; 
              params = { 
                keep = "10";
              }; 
            };
          };
        };
      };
    };
  }

  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [
      { from = 22000; to = 22000; } # Syncthing
      { from = 21027; to = 21027; } # Syncthing
    ];
    allowedUDPPortRanges = [
      { from = 22000; to = 22000; } # Syncthing
      { from = 21027; to = 21027; } # Syncthing
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

  system.stateVersion = "24.05"; # Did you read the comment?
}
