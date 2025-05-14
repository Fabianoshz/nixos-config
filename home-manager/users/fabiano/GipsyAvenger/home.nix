{ pkgs, lib, inputs, ... }:
{
  home.stateVersion = "24.11";

  imports = [
    ./syncthing.nix
    ./firefox.nix

    ../../../optional/kde/default.nix
    ../../../optional/zsh/default.nix
    ../../../optional/neovim/default.nix
    ../../../optional/flatpak/default.nix
  ];

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "discord"
        "libretro-snes9x"
        "steam-original"
        "steam-unwrapped"
        "steam"
      ];
    };
  };

  programs.home-manager.enable = true;

  programs.plasma = {
    configFile = {
      "kwinrc"."Xwayland"."Scale" = 1.75;
    };
  };

  xdg.autoStart.desktopItems = {
    steam = pkgs.makeDesktopItem {
      name = "Steam";
      exec = "steam";
      desktopName = "Steam";
    };
  };

  services.flatpak = {
    enable = true;
    update.auto = {
      enable = true;
      onCalendar = "weekly"; # Default value
    };
    packages = [
      "com.discordapp.Discord"
    ];
    uninstallUnmanaged = true;
  };

  home.username = "fabiano";
  home.homeDirectory = "/home/fabiano";
  home.sessionVariables = {
    EDITOR = "nvim";
    GTK_IM_MODULE = "cedilla";
    QT_IM_MODULE = "cedilla";
  };

  home.file = {
    # Enable CEF for decky-loader
    "/home/fabiano/.steam/steam/.cef-enable-remote-debugging" = {
      text = "";
      executable = false;
    };
  };

  home.packages = [
    pkgs.go-task
    pkgs.heroic
    pkgs.nexusmods-app
    pkgs.pcsx2
    pkgs.prismlauncher
    pkgs.steam-rom-manager
    pkgs.sunshine
    pkgs.unzip
    pkgs.usbutils
    pkgs.bash
    pkgs.dig
    pkgs.git
    pkgs.htop
    pkgs.itch

    # Rice stuff
    pkgs.papirus-icon-theme
    inputs.swww.packages.${pkgs.system}.swww
    inputs.lightly.packages.${pkgs.system}.darkly-qt5
    inputs.lightly.packages.${pkgs.system}.darkly-qt6
    pkgs.plasmusic-toolbar

    # KDE
    pkgs.kdePackages.elisa
    pkgs.kdePackages.filelight
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
      mupen64plus
      pcsx2
      snes9x
    ]))
  ];
}
