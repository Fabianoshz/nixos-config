{ config, pkgs, pkgs-unstable, lib, makeDesktopItem, inputs, ... }:
{
  home.stateVersion = "25.05";

  imports = [
    ./syncthing.nix
    ./firefox.nix

    ../../../optional/claude-md/default.nix
    ../../../optional/kde/default.nix
    ../../../optional/zsh/default.nix
    ../../../optional/git/default.nix
    ../../../optional/neovim/default.nix
  ];

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "claude-code"
        "discord"
	"grayjay"
        "obsidian"
        "steam-original"
        "steam-unwrapped"
        "steam"
      ];
    };
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
    pkgs.dbeaver-bin
    pkgs.discord
    pkgs.godot
    pkgs.iotop
    pkgs.keepassxc
    pkgs.obsidian
    pkgs.onlyoffice-bin
    pkgs.ssm-session-manager-plugin
    pkgs.steamtinkerlaunch
    pkgs.streamcontroller
    pkgs.unzip
    pkgs.usbutils
    pkgs.virt-manager
    pkgs.vlc
    pkgs.bash
    pkgs.dig
    pkgs.git
    pkgs.htop
 
    pkgs-unstable.claude-code
    pkgs-unstable.grayjay

    # Rice stuff
    pkgs.papirus-icon-theme
    inputs.lightly.packages.${pkgs.system}.darkly-qt5
    inputs.lightly.packages.${pkgs.system}.darkly-qt6
    pkgs.plasmusic-toolbar
    pkgs.plasma-panel-colorizer

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
    pkgs.kdePackages.signon-kwallet-extension
    pkgs.kdePackages.yakuake

    # PIM suite
    pkgs.kdePackages.akonadi
    pkgs.kdePackages.akonadi-calendar
    pkgs.kdePackages.akonadi-calendar-tools
    pkgs.kdePackages.akonadi-contacts
    pkgs.kdePackages.akonadi-import-wizard
    pkgs.kdePackages.akonadi-mime
    pkgs.kdePackages.akonadi-search
    pkgs.kdePackages.akonadiconsole
    pkgs.kdePackages.kaccounts-integration
    pkgs.kdePackages.kaccounts-providers
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
