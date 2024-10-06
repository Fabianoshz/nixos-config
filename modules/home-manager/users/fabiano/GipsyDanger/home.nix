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
    steam = pkgs.makeDesktopItem {
      name = "Stream Controller";
      exec = "streamcontroller -b";
      desktopName = "Stream Controller";
    };
  };

  home.packages = [
    pkgs.awscli2
    pkgs.dbeaver-bin
    pkgs.discord
    pkgs.filelight
    pkgs.firefox-bin
    pkgs.iotop
    pkgs.kcalc
    pkgs.kdePackages.merkuro
    pkgs.keepassxc
    pkgs.ns-usbloader
    pkgs.obsidian
    pkgs.onlyoffice-bin
    pkgs.pcsx2
    pkgs.postman
    pkgs.prismlauncher
    pkgs.ssm-session-manager-plugin
    pkgs.streamcontroller
    pkgs.temurin-jre-bin-17 # For pokeMMO
    pkgs.unzip
    pkgs.usbutils
    pkgs.virt-manager
    pkgs.vlc
    pkgs.yubikey-manager-qt
    pkgs.yubikey-personalization-gui

    # Refer: https://github.com/NixOS/nixpkgs/issues/263299
    # pkgs.kdePackages.signon-plugin-oauth2

    # KDE
    pkgs.kdePackages.kaccounts-integration
    pkgs.kdePackages.kaccounts-providers
    pkgs.kdePackages.kdeconnect-kde
    pkgs.kdePackages.konsole
    pkgs.kdePackages.krdc
    pkgs.kdePackages.xwaylandvideobridge
    pkgs.kdePackages.yakuake

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
