{ pkgs, lib, inputs, config, ... }:
{
  home.stateVersion = "26.05";

  imports = [
    ./syncthing.nix
    ./firefox.nix
    ./retroarch.nix
    ./pico8.nix

    ../../../optional/kde/default.nix
    # ../../../optional/zsh/default.nix
    ../../../optional/neovim/default.nix
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
    (pkgs.callPackage ../../../../pkgs/gen1recomp { })
    pkgs.dig
    pkgs.feishin
    pkgs.git
    pkgs.go-task
    pkgs.unzip
    pkgs.usbutils
    pkgs.vlc
    ((pkgs.unstable.amethyst-mod-manager.override {
      me3 = pkgs.emptyDirectory;
      umu-launcher = pkgs.emptyDirectory;
    }).overrideAttrs (old: {
      amethyst_filegraph = old.amethyst_filegraph.overrideAttrs (o: {
        nativeBuildInputs = (o.nativeBuildInputs or [ ]) ++ [ pkgs.unstable.pkg-config ];
        buildInputs = (o.buildInputs or [ ]) ++ [ pkgs.unstable.sqlite ];
      });
    }))

    (pkgs.unstable.grayjay.overrideAttrs (old: {
      preBuild = old.preBuild + ''
        mkdir -p JustCef/obj/justcef/net8.0/1/linux-arm64
        cp ${pkgs.fetchurl {
          url = "https://static.grayjay.app/justcef/1/JustCefNative-linux-arm64.zip";
          hash = "sha256-YmAvNmBLF2HaILdQeFC6PXei45rQscNjvmJa6R2Jlus=";
        }} JustCef/obj/justcef/net8.0/1/linux-arm64/JustCefNative-linux-arm64.zip
      '';
    }))

    # KDE
    pkgs.kdePackages.elisa
    pkgs.kdePackages.filelight
    pkgs.kdePackages.konsole
    pkgs.kdePackages.krdc
    pkgs.kdePackages.krfb
    pkgs.kdePackages.yakuake
  ];
}
