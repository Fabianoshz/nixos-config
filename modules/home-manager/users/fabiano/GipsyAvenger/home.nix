{ config, pkgs, pkgs-23-11, lib, inputs, ... }:
{
  imports = [
    ../common.nix
  ];

  home.stateVersion = "24.05";

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "discord"
        "libretro-snes9x"
        "steam-original"
        "steam"
      ];
    };
  };

  home.username = "fabiano";
  home.homeDirectory = "/home/fabiano";

  programs.home-manager.enable = true;

  xdg.desktopEntries = {
    youtube = {
      name = "Youtube";
      exec = "firefox -kiosk -new-window https://www.youtube.com/tv";
      categories = [ "Application" "Network" "WebBrowser" ];
      terminal = false;
    };
    zelda64recomp = {
      name = "Zelda 64 recomp";
      exec = "/home/fabiano/Games/Zelda64Recompiled-x86_64.AppImage";
      categories = [ "Game" ];
      terminal = false;
    };
  };

  programs.plasma = {
    configFile = {
      "kwinrc"."Xwayland"."Scale" = 1.75;
    };
  };

  home.sessionVariables = {
    GTK_IM_MODULE = "cedilla";
    QT_IM_MODULE = "cedilla";
  };

  home.packages = [
    pkgs.discord
    pkgs.filelight
    pkgs.heroic
    pkgs.iotop
    pkgs.ns-usbloader
    pkgs.pcsx2
    pkgs.prismlauncher
    pkgs.sunshine
    pkgs.unzip
    pkgs.usbutils

    pkgs-unstable.steam-rom-manager
    # pkgs-unstable.nexusmods-app

    pkgs-23-11.citra-canary

    # KDE
    pkgs.kdePackages.kdeconnect-kde
    pkgs.kdePackages.konsole
    pkgs.kdePackages.krdc
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
