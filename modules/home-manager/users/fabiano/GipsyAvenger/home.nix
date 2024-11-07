{ pkgs, lib, ... }:
{
  home.stateVersion = "24.11";

  imports = [
    ../common.nix
    ./syncthing.nix

    ../../../core/kde/default.nix
    ../../../core/zsh/default.nix
    ../../../optional/neovim/default.nix
    ../../../optional/pcsx2-qt-exec/default.nix
  ];

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "discord"
        "libretro-snes9x"
        "spotify"
        "steam-original"
        "steam-unwrapped"
        "steam"
      ];
    };
  };

  home.username = "fabiano";
  home.homeDirectory = "/home/fabiano";

  # Enable CEF for decky-loader
  home.file = {
    "/home/fabiano/.steam/steam/.cef-enable-remote-debugging" = {
      text = "";
      executable = false;
    };
  };

  programs.home-manager.enable = true;

  xdg.desktopEntries = {
    youtube = {
      name = "Youtube";
      exec = "firefox -kiosk -new-window https://www.youtube.com/tv";
      categories = [ "Network" "WebBrowser" ];
      terminal = false;
    };
    zelda64recomp = {
      name = "Zelda 64 recomp";
      exec = "/home/fabiano/Games/Zelda64Recompiled-x86_64.AppImage";
      categories = [ "Game" ];
      terminal = false;
    };
  };

  xdg.autoStart.desktopItems = {
    steam = pkgs.makeDesktopItem {
      name = "Steam";
      exec = "steam";
      desktopName = "Steam";
    };
  };

  programs.plasma = {
    configFile = {
      "kwinrc"."Xwayland"."Scale" = 1.75;
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    GTK_IM_MODULE = "cedilla";
    QT_IM_MODULE = "cedilla";
  };

  home.packages = [
    pkgs.filelight
    pkgs.firefox-bin
    pkgs.go-task
    pkgs.heroic
    pkgs.iotop
    pkgs.itch
    pkgs.nexusmods-app
    pkgs.ns-usbloader
    pkgs.pcsx2
    pkgs.prismlauncher
    pkgs.spotify
    pkgs.steam-rom-manager
    pkgs.sunshine
    pkgs.unzip
    pkgs.usbutils

    # KDE
    pkgs.kdePackages.kdeconnect-kde
    pkgs.kdePackages.konsole
    pkgs.kdePackages.krdc
    pkgs.kdePackages.krfb
    pkgs.kdePackages.yakuake

    (pkgs.retroarch.override {
      cores = with pkgs.libretro; [
        beetle-psx-hw
        beetle-saturn
        dolphin
        mame
        mgba
        mupen64plus
        ppsspp
        snes9x
      ];
    })
  ];
}
