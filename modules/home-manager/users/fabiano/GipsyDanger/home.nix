{ config, pkgs, pkgs-23-11, lib, inputs, ... }:
{
  imports = [
    ../common.nix
  ];

  home.username = "fabiano";
  home.homeDirectory = "/home/fabiano";

  programs.home-manager.enable = true;
  programs.gpg.homedir = "${config.xdg.dataHome}/gnupg";

  services.ssh-agent = {
    enable = true;
  };

  home.sessionVariables = {
    GTK_IM_MODULE = "cedilla";
    QT_IM_MODULE = "cedilla";
  };

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "discord"
        "irpf"
        "libretro-snes9x"
        "obsidian"
        "postman"
        "steam-original"
        "steam"
      ];
    };
  };

  home.packages = [
    (pkgs.callPackage ../../pkgs/optional/pkgs/vscode-runner/default.nix {inherit inputs;})

    pkgs.awscli2
    pkgs.dbeaver-bin
    pkgs.discord
    pkgs.filelight
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
    pkgs.unzip
    pkgs.usbutils
    pkgs.virt-manager
    pkgs.vlc
    pkgs.yubikey-manager-qt
    pkgs.yubikey-personalization-gui

    # Refer: https://github.com/NixOS/nixpkgs/issues/263299
    # pkgs.kdePackages.signon-plugin-oauth2

    pkgs-23-11.citra-canary

    # KDE
    pkgs.kdePackages.kdeconnect-kde
    pkgs.kdePackages.konsole
    pkgs.kdePackages.krdc
    pkgs.kdePackages.yakuake
    pkgs.kdePackages.kaccounts-integration
    pkgs.kdePackages.kaccounts-providers

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
