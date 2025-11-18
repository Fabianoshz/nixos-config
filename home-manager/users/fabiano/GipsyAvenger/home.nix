{ pkgs, lib, inputs, config, ... }:
let
  retroarchWithCores = pkgs.retroarch.withCores (cores: with cores; [
    beetle-psx-hw
    dolphin
    mupen64plus
    pcsx2
    snes9x
  ]);
in
{
  home.stateVersion = "25.11";

  imports = [
    ./syncthing.nix
    ./firefox.nix

    ../../../optional/kde/default.nix
    ../../../optional/zsh/default.nix
    ../../../optional/neovim/default.nix
    ../../../optional/flatpak/default.nix
    ../../../optional/retroarch/default.nix

    inputs.xdg-autostart.homeManagerModules.xdg-autostart
  ];

  programs.home-manager.enable = true;

  programs.plasma = {
    configFile = {
      "kwinrc"."Xwayland"."Scale" = 1.75;
    };
  };

  # TODO: This is not working because of sunshine
  # xdg.configFile."autostart/steam.desktop".source = "${pkgs.steam}/share/applications/steam.desktop";

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
            <emulator name="PROTON">
                <!-- umu-launcher for running Proton games -->
                <rule type="staticpath">
                    <entry>${pkgs.umu-launcher}/bin/umu-run</entry>
                </rule>
            </emulator>
            <emulator name="XENIA-WINDOWS">
                <!-- Xenia Canary Windows version -->
                <rule type="staticpath">
                    <entry>/home/fabiano/Applications/Xenia_canary/xenia_canary.exe</entry>
                </rule>
            </emulator>
        </ruleList>
      '';
      executable = false;
    };
  };

  home.packages = [
    pkgs.bash
    pkgs.dig
    pkgs.git
    pkgs.go-task
    pkgs.grayjay
    pkgs.htop
    pkgs.itch
    pkgs.nexusmods-app
    pkgs.pcsx2
    pkgs.prismlauncher
    pkgs.steam-rom-manager
    pkgs.umu-launcher
    pkgs.unzip
    pkgs.usbutils
    pkgs.wowup-cf
    pkgs.xenia-canary

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

    retroarchWithCores
  ];
}
