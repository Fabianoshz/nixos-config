{ config, pkgs, lib, makeDesktopItem, ... }:
{
  home.stateVersion = "24.11";

  imports = [
    ../common.nix
    ./syncthing.nix

    ../../../core/kde/default.nix
    ../../../core/zsh/default.nix
    ../../../optional/git/default.nix
    ../../../optional/neovim/default.nix
    ../../../optional/vscode/default.nix
  ];

  home.username = "fabiano";
  home.homeDirectory = "/home/fabiano";

  programs.home-manager.enable = true;
  programs.gpg.homedir = "${config.xdg.dataHome}/gnupg";
  programs.tmux.enable = true;
  programs.tmux.keyMode = "emacs";

  services.ssh-agent = {
    enable = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "discord"
        "irpf"
        "libretro-snes9x"
        "obsidian"
        "postman"
        "spotify"
        "steam-original"
        "steam-unwrapped"
        "steam"
        "vscode-extension-github-copilot"
      ];
    };
  };

  xdg.desktopEntries = {
    pokemmo = {
      name = "PokeMMO";
      exec = "steam-run /home/fabiano/Games/PokeMMO-Client/PokeMMO.sh";
      icon = "/home/fabiano/Games/PokeMMO-Client/data/icons/128x128.png";
      categories = [ "Game" ];
      terminal = false;
      settings = {
        Path = "/home/fabiano/Games/PokeMMO-Client";
      };
    };
  };

  xdg.autoStart.desktopItems = {
    StreamController = pkgs.makeDesktopItem {
      name = "StreamController";
      exec = "streamcontroller -b";
      desktopName = "Stream Controller";
      icon = "streamcontroller";
      type = "Application";
      categories = ["Utility"];
      startupNotify = true;
      terminal = false;
      comment = "Control your Elgato Stream Decks";
    };

    Yakuake = pkgs.makeDesktopItem {
      name = "org.kde.yakuake.desktop";
      genericName = "Drop-down Terminal";
      dbusActivatable = true;
      exec = "yakuake";
      desktopName = "Yakuake";
      icon = "yakuake";
      type = "Application";
      categories = ["Qt" "KDE" "System" "TerminalEmulator"];
      startupNotify = false;
      terminal = false;
      comment = "A drop-down terminal emulator based on KDE Konsole technology.";
    };
  };

  home.sessionVariables = {
    DOCKER_CONFIG = "${config.xdg.configHome}/docker";
    ELECTRUMDIR = "${config.xdg.dataHome}/electrum";
    GNUPGHOME = "${config.xdg.dataHome}/gnupg";
    KUBECACHEDIR = "${config.xdg.cacheHome}/kube";
    KUBECONFIG = "${config.xdg.configHome}/kube/kubeconfig";
    LESSHISTFILE = "${config.xdg.cacheHome}/less/history";
    MINIKUBE_HOME = "${config.xdg.dataHome}/minikube";
    NPM_CONFIG_CACHE = "${config.xdg.cacheHome}/npm";
    NPM_CONFIG_TMP = "$XDG_RUNTIME_DIR/npm";
    NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm/config";
    RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
    WINEPREFIX = "${config.xdg.dataHome}/wine";
    XCOMPOSECACHE = "${config.xdg.cacheHome}/X11/xcompose";
    ZPLUG_HOME = "${config.xdg.dataHome}/zplug";
  };

  home.packages = [
    pkgs.awscli2
    pkgs.dbeaver-bin
    pkgs.discord
    pkgs.filelight
    pkgs.firefox-bin
    pkgs.hoppscotch
    pkgs.iotop
    pkgs.kcalc
    pkgs.keepassxc
    pkgs.obsidian
    pkgs.onlyoffice-bin
    pkgs.parabolic
    pkgs.pcsx2
    pkgs.postman
    pkgs.ssm-session-manager-plugin
    pkgs.steamtinkerlaunch
    pkgs.streamcontroller
    pkgs.unzip
    pkgs.usbutils
    pkgs.virt-manager

    # pkgs.anki-bin
    # pkgs.delfin
    # pkgs.nexusmods-app
    # pkgs.ns-usbloader
    # pkgs.prismlauncher
    # pkgs.temurin-jre-bin-17 # For pokeMMO
    # pkgs.vlc
    # pkgs.wireshark
    # pkgs.yubikey-manager-qt
    # pkgs.yubikey-personalization-gui

    # Refer: https://github.com/NixOS/nixpkgs/issues/263299
    # pkgs.kdePackages.signon-plugin-oauth2

    # KDE
    pkgs.kdePackages.kaccounts-integration
    pkgs.kdePackages.kaccounts-providers
    pkgs.kdePackages.kdeconnect-kde
    pkgs.kdePackages.konsole
    pkgs.kdePackages.krdc
    pkgs.kdePackages.merkuro
    pkgs.kdePackages.qtlocation
    pkgs.kdePackages.xwaylandvideobridge
    pkgs.kdePackages.yakuake

    # TODO: retroarch will change in the future
    # (pkgs.retroarch.withCores (cores: with cores; [
    #   beetle-psx-hw
    #   beetle-saturn
    #   dolphin
    #   gambatte
    #   mame
    #   melonds
    #   mgba
    #   mupen64plus
    #   ppsspp
    #   snes9x
    # ]))

    (pkgs.retroarch.override {
      cores = with pkgs.libretro; [
        beetle-psx-hw
        beetle-saturn
        dolphin
        gambatte
        mame
        melonds
        mgba
        mupen64plus
        ppsspp
        snes9x
      ];
    })
  ];
}
