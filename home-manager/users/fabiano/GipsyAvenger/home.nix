{ pkgs, lib, inputs, config, ... }:
let
  retroarchWithCores = pkgs.retroarch.withCores (cores: with cores; [
    beetle-psx-hw
    beetle-saturn
    # dolphin
    mame
    mupen64plus
    # pcsx2
    snes9x
  ]);
in
{
  home.stateVersion = "25.11";

  imports = [
    ./syncthing.nix
    ./firefox.nix
    ./flatpak.nix

    ../../../optional/kde/default.nix
    ../../../optional/zsh/default.nix
    ../../../optional/neovim/default.nix
    ../../../optional/flatpak/default.nix
  ];

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "libretro-snes9x"
        "steam"
        "steam-original"
        "steam-unwrapped"
      ];
    };
  };

  programs.home-manager.enable = true;

  programs.plasma = {
    configFile = {
      "kwinrc"."Xwayland"."Scale" = 1.75;
    };
  };

  xdg.configFile."autostart/steam.desktop".source = "${pkgs.steam}/share/applications/steam.desktop";

  home.username = "fabiano";
  home.homeDirectory = "/home/fabiano";
  home.sessionVariables = {
    SYSTEMD_EDITOR = "nvim";
    EDITOR = "nvim";
    GTK_IM_MODULE = "cedilla";
    QT_IM_MODULE = "cedilla";
  };

  home.file = {
    # Enable CEF for decky-loader
    "${config.home.homeDirectory}/.steam/steam/.cef-enable-remote-debugging" = {
      text = "";
      executable = false;
    };

    # Add cores to ES-DE appimage
    "${config.home.homeDirectory}/ES-DE/custom_systems/es_find_rules.xml" = {
      text = ''
        <?xml version="1.0"?>
        <!-- This is the ES-DE find rules configuration file for Linux -->
        <ruleList>
            <core name="RETROARCH">
                <rule type="corepath">
                    <!-- Nixos retroarch cores path -->
                    <entry>${retroarchWithCores}/lib/retroarch/cores</entry>
                </rule>
            </core>
        </ruleList>
      '';
      executable = false;
    };
  };



  home.packages = [
    pkgs.bash
    pkgs.dig
    pkgs.flatpak
    pkgs.git
    pkgs.go-task
    pkgs.heroic
    pkgs.htop
    pkgs.itch
    pkgs.nexusmods-app
    pkgs.pcsx2
    pkgs.prismlauncher
    pkgs.steam-rom-manager
    pkgs.unzip
    pkgs.usbutils

    # Rice stuff
    inputs.lightly.packages.${pkgs.system}.darkly-qt5
    inputs.lightly.packages.${pkgs.system}.darkly-qt6
    pkgs.papirus-icon-theme
    pkgs.plasmusic-toolbar

    # KDE
    pkgs.kdePackages.elisa
    pkgs.kdePackages.filelight
    pkgs.kdePackages.kdeconnect-kde
    pkgs.kdePackages.konsole
    pkgs.kdePackages.krdc
    pkgs.kdePackages.krfb
    pkgs.kdePackages.yakuake

    pkgs.xenia-canary
    retroarchWithCores
  ];
}
