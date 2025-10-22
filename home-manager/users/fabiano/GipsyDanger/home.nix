{ config, pkgs, lib, inputs, ... }:
{
  home.stateVersion = "25.05";

  imports = [
    ./firefox.nix
    ./syncthing.nix

    ../../../optional/claude-md/default.nix
    ../../../optional/git/default.nix
    ../../../optional/kde/default.nix
    ../../../optional/neovim/default.nix
    ../../../optional/zsh/default.nix
  ];

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "discord"
        "obsidian"
        "steam"
        "steam-original"
        "steam-unwrapped"
      ];
    };
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

  programs.home-manager.enable = true;
  programs.gpg.homedir = "${config.xdg.dataHome}/gnupg";

  xdg.autoStart.desktopItems = {
    StreamController = pkgs.makeDesktopItem {
      name = "StreamController";
      exec = "streamcontroller -b";
      desktopName = "Stream Controller";
      icon = "streamcontroller";
      type = "Application";
      categories = [ "Utility" ];
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
      categories = [ "Qt" "KDE" "System" "TerminalEmulator" ];
      startupNotify = false;
      terminal = false;
      comment = "A drop-down terminal emulator based on KDE Konsole technology.";
    };
  };

  xdg.desktopEntries.actual = {
    name = "Actual Budget";
    exec = "appimage-run /home/fabiano/Applications/Actual-linux-x86_64.AppImage";
    terminal = false;
    type = "Application";
  };

  services.ssh-agent = {
    enable = true;
  };

  home.username = "fabiano";
  home.homeDirectory = "/home/fabiano";
  home.sessionVariables = {
    DOCKER_CONFIG = "${config.xdg.configHome}/docker";
    SYSTEMD_EDITOR = "nvim";
    EDITOR = "nvim";
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
    pkgs.bash
    pkgs.dbeaver-bin
    pkgs.dig
    pkgs.discord
    pkgs.git
    pkgs.godot
    pkgs.htop
    pkgs.iotop
    pkgs.keepassxc
    pkgs.moonlight-qt
    pkgs.nexusmods-app
    pkgs.obsidian
    pkgs.onlyoffice-bin
    pkgs.ripgrep
    pkgs.rofi
    pkgs.ssm-session-manager-plugin
    pkgs.steamtinkerlaunch
    pkgs.streamcontroller
    pkgs.unzip
    pkgs.usbutils
    pkgs.virt-manager
    pkgs.vlc

    pkgs.unstable.claude-code
    pkgs.unstable.grayjay
    pkgs.unstable.planify

    # Rice stuff
    inputs.lightly.packages.${pkgs.system}.darkly-qt5
    inputs.lightly.packages.${pkgs.system}.darkly-qt6
    pkgs.papirus-icon-theme
    pkgs.plasma-panel-colorizer
    pkgs.plasmusic-toolbar
    inputs.kwin-effects-forceblur.packages.${pkgs.system}.default

    # KDE
    pkgs.kdePackages.calendarsupport
    pkgs.kdePackages.dolphin
    pkgs.kdePackages.dolphin-plugins
    pkgs.kdePackages.elisa
    pkgs.kdePackages.filelight
    pkgs.kdePackages.gwenview
    pkgs.kdePackages.kate
    pkgs.kdePackages.kcalc
    pkgs.kdePackages.kdeconnect-kde
    pkgs.kdePackages.konsole
    pkgs.kdePackages.kontact
    pkgs.kdePackages.korganizer
    pkgs.kdePackages.kpimtextedit
    pkgs.kdePackages.kwalletmanager
    pkgs.kdePackages.okular
    pkgs.kdePackages.yakuake

    # PIM suite
    pkgs.kdePackages.akonadi
    pkgs.kdePackages.akonadi-calendar
    pkgs.kdePackages.akonadi-calendar-tools
    pkgs.kdePackages.akonadi-contacts
    pkgs.kdePackages.akonadi-import-wizard
    pkgs.kdePackages.akonadi-mime
    pkgs.kdePackages.akonadi-search
    pkgs.kdePackages.kdepim-addons
    pkgs.kdePackages.kdepim-runtime
    pkgs.kdePackages.kmail-account-wizard
    pkgs.kdePackages.kmailtransport
    pkgs.kdePackages.mailcommon
    pkgs.kdePackages.mailimporter
    pkgs.kdePackages.pim-data-exporter
    pkgs.kdePackages.pim-sieve-editor
    pkgs.kdePackages.pimcommon
  ];
}
