{ config, pkgs, lib, makeDesktopItem, inputs, ... }:
{
  home.stateVersion = "24.11";

  imports = [
    ./syncthing.nix
    ./firefox.nix

    ../../../optional/kde/default.nix
    ../../../optional/zsh/default.nix
    ../../../optional/git/default.nix
    ../../../optional/neovim/default.nix
  ];

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
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
    pkgs.grayjay
 
    # Rice stuff
    pkgs.papirus-icon-theme
    inputs.swww.packages.${pkgs.system}.swww
    inputs.lightly.packages.${pkgs.system}.darkly-qt5
    inputs.lightly.packages.${pkgs.system}.darkly-qt6
    pkgs.plasmusic-toolbar
    pkgs.plasma-panel-colorizer

    # KDE
    pkgs.kdePackages.akregator
    pkgs.kdePackages.elisa
    pkgs.kdePackages.filelight
    pkgs.kdePackages.kcalc
    pkgs.kdePackages.kdeconnect-kde
    pkgs.kdePackages.konsole
    pkgs.kdePackages.krdc
    pkgs.kdePackages.merkuro
    pkgs.kdePackages.qtlocation
    pkgs.kdePackages.xwaylandvideobridge
    pkgs.kdePackages.yakuake

    pkgs.kdePackages.kcontacts
    pkgs.kdePackages.kaddressbook
    pkgs.kdePackages.kpeople
    pkgs.kdePackages.kontact
  ];
}
