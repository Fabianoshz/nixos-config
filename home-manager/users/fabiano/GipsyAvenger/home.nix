{ pkgs, lib, inputs, config, ... }:
let
  retroarchWithCores = import ./retroarch.nix { inherit pkgs; };
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

  services.home-manager.autoExpire = {
    enable = true;
    timestamp = "-30 days";
    frequency = "weekly";
  };

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
  };

  home.packages = [
    pkgs.bash
    pkgs.dig
    pkgs.discord
    pkgs.git
    pkgs.go-task
    pkgs.grayjay
    pkgs.htop
    pkgs.itch
    pkgs.prismlauncher
    pkgs.steam-rom-manager
    pkgs.unzip
    pkgs.usbutils

    # Rice stuff
    inputs.lightly.packages.${pkgs.stdenv.hostPlatform.system}.darkly-qt5
    inputs.lightly.packages.${pkgs.stdenv.hostPlatform.system}.darkly-qt6
    pkgs.papirus-icon-theme

    # KDE
    pkgs.kdePackages.elisa
    pkgs.kdePackages.filelight
    pkgs.kdePackages.kdeconnect-kde
    pkgs.kdePackages.konsole
    pkgs.kdePackages.qtbase
    pkgs.kdePackages.yakuake

    retroarchWithCores
  ];
}
