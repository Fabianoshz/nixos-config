{ pkgs, lib, inputs, config, ... }:
let
  retroarchWithCores = pkgs.retroarch.withCores (cores: with cores; [
    # Build this from source
    # azahar
    melonds
    gambatte
    mgba
    ppsspp
  ]);
in
{
  home.stateVersion = "26.05";

  imports = [
    ./syncthing.nix
    ./firefox.nix

    ../../../optional/kde/default.nix
    # ../../../optional/zsh/default.nix
    # ../../../optional/neovim/default.nix
    ../../../optional/flatpak/default.nix

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
  };

  home.packages = [
    pkgs.bash
    pkgs.boilr
    pkgs.dig
    pkgs.git
    pkgs.go-task
    pkgs.htop
    pkgs.unzip
    pkgs.usbutils

    pkgs.azahar
    pkgs.melonds

    # No aarch64? :(
    # pkgs.steam-rom-manager

    # KDE
    pkgs.kdePackages.elisa
    pkgs.kdePackages.filelight
    pkgs.kdePackages.kdeconnect-kde
    pkgs.kdePackages.konsole
    pkgs.kdePackages.krdc
    pkgs.kdePackages.krfb
    pkgs.kdePackages.qtbase
    pkgs.kdePackages.yakuake

    retroarchWithCores
  ];
}
