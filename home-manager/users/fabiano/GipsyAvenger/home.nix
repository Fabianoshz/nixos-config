{ pkgs, lib, inputs, ... }:
{
  home.stateVersion = "24.11";

  imports = [
    ./syncthing.nix
    ./firefox.nix

    ../../../optional/kde/default.nix
    ../../../optional/zsh/default.nix
    ../../../optional/neovim/default.nix
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

  services.flatpak.enable = true;
  services.flatpak.update.auto = {
    enable = true;
    onCalendar = "weekly"; # Default value
  };
  services.flatpak.packages = [
    "com.discordapp.Discord"
    "com.steamgriddb.steam-rom-manager"
    "io.itch.itch"
  ];
  services.flatpak.uninstallUnmanaged = true;

  home.packages = [
    pkgs.filelight
    pkgs.go-task
    pkgs.heroic
    pkgs.nexusmods-app
    pkgs.pcsx2
    pkgs.prismlauncher
    pkgs.spotify
    pkgs.steam-rom-manager
    pkgs.sunshine
    pkgs.unzip
    pkgs.usbutils
    pkgs.bash
    pkgs.dig
    pkgs.git
    pkgs.htop

    # Rice stuff
    pkgs.papirus-icon-theme
    inputs.swww.packages.${pkgs.system}.swww
    inputs.lightly.packages.${pkgs.system}.darkly-qt5
    inputs.lightly.packages.${pkgs.system}.darkly-qt6
    pkgs.plasmusic-toolbar

    # KDE
    pkgs.kdePackages.kdeconnect-kde
    pkgs.kdePackages.konsole
    pkgs.kdePackages.krdc
    pkgs.kdePackages.krfb
    pkgs.kdePackages.yakuake

    (pkgs.retroarch.withCores (cores: with cores; [
      beetle-psx-hw
      beetle-saturn
      dolphin
      mame
      mgba
      mupen64plus
      pcsx2
      ppsspp
      snes9x
    ]))
  ];
}
