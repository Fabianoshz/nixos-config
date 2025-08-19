{ pkgs, lib, ... }:

{
  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "steam"
        "steam-jupiter-original"
        "steam-jupiter-unwrapped"
        "steam-original"
        "steam-run"
        "steam-unwrapped"
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
      pkgs.python313Packages.hid
    ];

    # Got from: https://plugins.deckbrew.xyz/plugins
    plugins = {
      "MagicPodsDecky" = {
        src = pkgs.fetchzip {
          url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/598f1e27f39972317a1f8f9b5b351bf0415a4ca8cf7cbfeec28fdab02207abab.zip";
          sha256 = "sha256-dkoEPwyEcLcQL9FMPWkVfWHZfxKC6UgaUlrsZE2JRn0";
          extension = "zip";
          stripRoot = true;
        };
      };
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
          url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/6bc09af6ce16bf3437dc100129940310481338bbf2b198ed702854ed193d2e46.zip";
          sha256 = "sha256-0Hvmuu/Fm2mzk7nloq/azTTXsZOm/PGYoIL4bH6LFJE=";
          extension = "zip";
          stripRoot = true;
        };
      };
      "tab-master" = {
        src = pkgs.fetchzip {
          url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/26bc5b36dd4e0ffdde3e4fc89eb3862ebce9fb1d5f95b3aa3b1ad209f13976c0.zip";
          sha256 = "sha256-UPhCqod+QbswqXrdmsowQcZ6UFOgskSogbAnhDhNbBQ=";
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
          url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/98dcb443e81b9f9011cfe77c69eb659869c8e2df2df8b0a443df66cbfc2f5a89.zip";
          sha256 = "sha256-28uGij7iqBEFvyzKAnuHXY5MRqfBs3ica0ckqXeYaBI=";
          extension = "zip";
          stripRoot = true;
        };
      };
    };
  };
}

