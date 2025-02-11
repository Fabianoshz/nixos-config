{ pkgs, lib, ... }:

{
  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "steam-jupiter-original"
        "steam-jupiter-unwrapped"
        "steam-original"
        "steam-run"
        "steam-unwrapped"
        "steam"
        "steamdeck-hw-theme"
      ];
    };
  };

  jovian = {
    hardware.has.amd.gpu = true;
    devices.steamdeck.enable = false;

    steam = {
      autoStart = true;
      desktopSession = "plasma";
      enable = true;
      updater.splash = "vendor";
      user = "fabiano";
    };

    steamos = {
      enableProductSerialAccess = false;
      useSteamOSConfig = false;
    };
  };

  jovian.decky-loader = {
    enable = true;
    user = "fabiano";

    extraPackages = [
      pkgs.curl
      pkgs.dbus # For MusicControl plugin
      pkgs.python3
      pkgs.util-linux # Has 'rev' for MusicControl plugin
    ];
    extraPythonPackages = pythonPackages: [
      pkgs.python312Packages.hid
    ];

    # Got from: https://plugins.deckbrew.xyz/plugins
    plugins = {
      "SDH-CssLoader" = {
        src = pkgs.fetchzip {
          url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/1a1e8f4dded8494febe56df16429ef5bba1e5b8feb3fd989d5808fbef0d71350.zip";
          sha256 = "sha256-PoJNP6kqwTQphJxrgWq+uLCXjpcpAeJQ2Xu6d8UW6OY=";
          extension = "zip";
          stripRoot = true;
        };
      };
      "SDH-GameThemeMusic" = {
        src = pkgs.fetchzip {
          url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/2a9fced36b3d34bd4bd4bd7963787b486bf39137f9d444632140ab1fe1872de8.zip";
          sha256 = "sha256-2TXWSDuKJKdnjHA3hRSTtacuTijdXtwuMAnCZCZ4akw=";
          extension = "zip";
          stripRoot = true;
        };
      };
      "protondb-decky" = {
        src = pkgs.fetchzip {
          url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/3894048d0d9b35342c85d9f50e9e5e4edc00b65e9dfe61d47ec5cf97bfd28da7.zip";
          sha256 = "sha256-iwoor0at8mYc6Ys+lh0GvhC/RaupMqvUe8G/sR0dNVQ=";
          extension = "zip";
          stripRoot = true;
        };
      };
      "SteamGridDB" = {
        src = pkgs.fetchzip {
          url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/b84f0a3f83b6e5d7cbc0ba9360bde33cfb400cf5f2a5d5c38f44a488e2c91a57.zip";
          sha256 = "sha256-0Hvmuu/Fm2mzk7nloq/azTTXsZOm/PGYoIL4bH6LFJE=";
          extension = "zip";
          stripRoot = true;
        };
      };
      "tab-master" = {
        src = pkgs.fetchzip {
          url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/eb74a08f8aa6f89808740424ce0f12670409ce9c15776cd623d3b4e4c9a8f52b.zip";
          sha256 = "sha256-eqOCRyuUqZ+9y2KRWWfIn5uJ+KjaB3J6LUS5mTaWQHQ=";
          extension = "zip";
          stripRoot = true;
        };
      };
      "MusicControl" = {
        src = pkgs.fetchzip {
          url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/246b89fd653c60a735b1cc401d1b0937d5cb969eea9024561661ff741f081d62.zip";
          sha256 = "sha256-Ow0cvecOd/ZO7j5Xur3rRz+CAE5l/4pX3qGNcJ6wmF4=";
          extension = "zip";
          stripRoot = true;
        };
      };
      "Emuchievements" = {
        src = pkgs.fetchzip {
          url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/d9d43e9d0720615d109746a658fbbfd4b0d69e69b7444310e25ad62e415f7980.zip";
          sha256 = "sha256-28uGij7iqBEFvyzKAnuHXY5MRqfBs3ica0ckqXeYaBI=";
          extension = "zip";
          stripRoot = true;
        };
      };
    };
  };
}

