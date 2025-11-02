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
      pkgs.p7zip # For framegen plugin
      pkgs.python3
      pkgs.util-linux # Has 'rev' for MusicControl plugin
    ];
    extraPythonPackages = pythonPackages: [
      pkgs.python313Packages.hid
    ];

    # Got from: https://plugins.deckbrew.xyz/plugins
    plugins = {
      # This is not working :(
      "MagicPodsDecky" = {
        src = pkgs.fetchzip {
          url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/fa7407d44069ee54e92ed8bd44a0462b73e96a63060ac7524581684c21c15779.zip";
          sha256 = "sha256-B5svfH56Xk0+bZRgM1DOxZ+k75aufHVmUCDP2HfIXE0=";
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
          url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/9ce293ab4db212c03c6b96dfbc5e4d92e874d33387463f53223773921f75a80e.zip";
          sha256 = "sha256-2J5kDcw5Pwih2j12BH5Pvx4vA11wtFlMaB0NzMeFM1k=";
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
          url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/f18279dc95b6ee003a7f53a84e8f7eee3a8fdd042ef67e5160c91c31ad12659f.zip";
          sha256 = "sha256-pJLPuz9OGmMCbZv2BThIApksp6riBRruEUeMvm5iyfs=";
          extension = "zip";
          stripRoot = true;
        };
      };
      "tab-master" = {
        src = pkgs.fetchzip {
          url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/7a0afa10df0e2e012f7aed28d818820fe03a6c154af190dda31264dca4a3a69a.zip";
          sha256 = "sha256-MA3Gf/sDeD4amWg4RJoCfM2iNBCKwYR8SeGZxDFNbUw=";
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
          sha256 = "sha256-HSeDCEC+qu4HPULjf5SbnsnS7H9OHDXTknLf/3IeXDA=";
          extension = "zip";
          stripRoot = true;
        };
      };
      "decky-pip" = {
        src = pkgs.fetchzip {
          url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/e0115148305cd216e50bcfec8851fe3d1c6f3d36ae2f92113c199fc1bb2388e3.zip";
          sha256 = "sha256-GAYPJH9dK73191zQhf+0WmvV9c+KMyHJC1JItpQoDUY=";
          extension = "zip";
          stripRoot = true;
        };
      };
      "decky-framegen" = {
        src = pkgs.fetchzip {
          url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/14015d5a652c78b2041fd9668685573840530c306e414aabc0d3cebf95be0642.zip";
          sha256 = "sha256-zLdX7hQRtGELrRh+hj0JA19FZyMak5Ad8HE5f3Dti/s=";
          extension = "zip";
          stripRoot = true;
        };
      };
      "controller-tools" = {
        src = pkgs.fetchzip {
          url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/9450e54cbf28082d4513838d0dcd42bf04ffc08ae5a6472d0c1f88677782e3ef.zip";
          sha256 = "sha256-+cmM3dJMj/wGAD7VwdZW03vpXQyL2aI2tB0zLYU0Jyk";
          extension = "zip";
          stripRoot = true;
        };
      };

      # Not working yet (has dynamic linked programs)
      # "wine-cellar" = {
      #   src = pkgs.fetchzip {
      #     url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/a400c89e853117e32e2fba77ef1b09d8f3e9e9d073b9af38af7c73ed525cac6d.zip";
      #     sha256 = "sha256-cYfys83oEPoGuDsbfli9zFA4A9ySVWoYeMg/WWlKN34=";
      #     extension = "zip";
      #     stripRoot = true;
      #   };
      # };
      # "decky-syncthing" = {
      #   src = pkgs.fetchzip {
      #     url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/1424128571b59536909095146959acba3a36899a69e3d2d790f630f2c7bc607e.zip";
      #     sha256 = "sha256-pzv8nXm4pMjhQzzFeB348zLVCfpaWv6CjMQSYS5dLUY";
      #     extension = "zip";
      #     stripRoot = true;
      #   };
      # };
    };
  };
}
