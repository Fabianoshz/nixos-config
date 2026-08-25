{ pkgs, lib, ... }:

let
  # tender.zip ships a duplicate README.md entry, which fetchzip's unzip (run
  # without -o) can't unpack in the sandbox (it hits an overwrite prompt and
  # aborts). Fetch the raw zip and unpack with forced overwrite instead,
  # stripping the top-level romm-tender/ dir.
  tenderSrc = pkgs.runCommand "tender-0.31.0"
    {
      src = pkgs.fetchurl {
        url = "https://github.com/danielcopper/romm-tender/releases/download/tender-v0.31.0/tender.zip";
        hash = "sha256-dLov4HdeOUldsYC7cwM5Dr9xI8zR3gi1XBE4bHXoR/I=";
      };
      nativeBuildInputs = [ pkgs.unzip ];
    } ''
    mkdir unpacked
    unzip -o -q $src -d unpacked
    cp -r unpacked/romm-tender $out
  '';
in
{
  jovian = {
    hardware.has.amd.gpu = true;
    devices.steamdeck.enable = false;
    devices.steamdeck.enablePerfControlUdevRules = true;

    steam = {
      autoStart = true;
      desktopSession = "plasma";
      enable = true;
      updater.splash = "vendor";
      user = "fabiano";
    };

    steamos = {
      enableProductSerialAccess = false;
      enableSysctlConfig = true;
      useSteamOSConfig = false;
    };

    decky-loader = {
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
        pythonPackages.hid
      ];

      # Got from: https://plugins.deckbrew.xyz/plugins
      plugins = {
        "controller-tools" = {
          src = pkgs.fetchzip {
            url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/9450e54cbf28082d4513838d0dcd42bf04ffc08ae5a6472d0c1f88677782e3ef.zip";
            sha256 = "sha256-+cmM3dJMj/wGAD7VwdZW03vpXQyL2aI2tB0zLYU0Jyk";
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
        "protondb-decky" = {
          src = pkgs.fetchzip {
            url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/54fadb8faec26bb8667a6fd7c61167bc4e5584414f142ae455c74a381ee23891.zip";
            sha256 = "sha256-qy2Pt1MQCZ7CxJBj/POigOUC28iCbb1PPjpN1GKYRX8=";
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
        "SteamGridDB" = {
          src = pkgs.fetchzip {
            url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/6d6eca184677dc9ff7736439ee7a575ca8ab386c5ffb1627d446bc43dbd1ecf3.zip";
            sha256 = "sha256-hYPsrC5QA0eX/fYkEnzIDB0p77Feo4IkKrJ6IKfjtFw=";
            extension = "zip";
            stripRoot = true;
          };
        };
        "tab-master" = {
          src = pkgs.fetchzip {
            url = "https://github.com/Tormak9970/TabMaster/releases/download/v2.15.1/TabMaster_v2.15.1.zip";
            sha256 = "sha256-ni2KJtvNCNt5OGMW788H0D7z8XgcCrnkisU0gCRAEt0=";
            extension = "zip";
            stripRoot = true;
          };
        };
        "Tender" = {
          src = tenderSrc;
        };

        # "SDH-GameThemeMusic" = {
        #   src = pkgs.fetchzip {
        #     url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/9ce293ab4db212c03c6b96dfbc5e4d92e874d33387463f53223773921f75a80e.zip";
        #     sha256 = "sha256-2J5kDcw5Pwih2j12BH5Pvx4vA11wtFlMaB0NzMeFM1k=";
        #     extension = "zip";
        #     stripRoot = true;
        #   };
        # };
        # "Emuchievements" = {
        #   src = pkgs.fetchzip {
        #     url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/98dcb443e81b9f9011cfe77c69eb659869c8e2df2df8b0a443df66cbfc2f5a89.zip";
        #     sha256 = "sha256-HSeDCEC+qu4HPULjf5SbnsnS7H9OHDXTknLf/3IeXDA=";
        #     extension = "zip";
        #     stripRoot = true;
        #   };
        # };
      };
    };
  };
}
