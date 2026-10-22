{ pkgs, lib, inputs, config, ... }:
{
  home.stateVersion = "26.05";

  imports = [
    ./syncthing.nix
    ./firefox.nix
    ./melonds.nix
    ./azahar.nix
    ./retroarch.nix

    ../../../optional/kde/default.nix
    # ../../../optional/zsh/default.nix
    # ../../../optional/neovim/default.nix
    ../../../optional/flatpak/default.nix

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
    "${config.home.homeDirectory}/.local/share/Steam/.cef-enable-remote-debugging" = {
      text = "";
      executable = false;
    };
  };

  home.packages = [
    (pkgs.callPackage ../../../../pkgs/vita3k { })
    pkgs.bash
    pkgs.dig
    pkgs.feishin
    pkgs.git
    pkgs.go-task
    pkgs.htop
    pkgs.unzip
    pkgs.usbutils
    pkgs.vlc

    # KDE
    pkgs.kdePackages.elisa
    pkgs.kdePackages.filelight
    pkgs.kdePackages.kdeconnect-kde
    pkgs.kdePackages.konsole
    pkgs.kdePackages.krdc
    pkgs.kdePackages.krfb
    pkgs.kdePackages.qtbase
    pkgs.kdePackages.yakuake
  ];
}
