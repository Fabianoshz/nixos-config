{ config, pkgs, lib, ... }:

let
  retroarchWithCores = import ../../../home-manager/users/fabiano/GipsyAvenger/retroarch.nix { inherit pkgs; };
  romm-tender = pkgs.callPackage ../../../pkgs/romm-tender { retroarch = retroarchWithCores; };
  decky-pip = pkgs.callPackage ../../../pkgs/decky-pip { };
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
        pkgs.ffmpeg # For GameThemeMusic plugin
        pkgs.p7zip # For framegen plugin
        pkgs.python3
      ];
      extraPythonPackages = pythonPackages: [
        pythonPackages.hid
      ];

      # Got from: https://plugins.deckbrew.xyz/plugins
      plugins = {
        "decky-framegen" = {
          src = pkgs.fetchzip {
            url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/14015d5a652c78b2041fd9668685573840530c306e414aabc0d3cebf95be0642.zip";
            sha256 = "sha256-zLdX7hQRtGELrRh+hj0JA19FZyMak5Ad8HE5f3Dti/s=";
            extension = "zip";
            stripRoot = true;
          };
        };
        "decky-pip" = {
          src = decky-pip;
        };
        "protondb-decky" = {
          src = pkgs.fetchzip {
            url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/90a3453ac02709cad64096e7539fd8141fa56f99ae3441fc24a4990dc9684358.zip";
            sha256 = "sha256-+eNQRS2bW5dseLKsbP+pwZC/9QhaCjQDKLz9CWjzh+U=";
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
            url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/e84f5b1f111af8862b06218479491fbf61036e1bfd9f16f93f9901e9b9ebc5e0.zip";
            sha256 = "sha256-J/2vQhCAeBpWakz3jI3uihkrGNFCozYOLejTP4HVInU=";
            extension = "zip";
            stripRoot = true;
          };
        };
        "tab-master" = {
          src = pkgs.fetchzip {
            url = "https://github.com/Tormak9970/TabMaster/releases/download/v2.16.2/TabMaster_v2.16.2.zip";
            sha256 = "sha256-kUfEJ3X8Bwv8FIIfOvTUeMvmwmFpZdRr9apmC6cfOzM=";
            extension = "zip";
            stripRoot = true;
          };
        };
        "Tender" = {
          src = romm-tender;
        };
        "SDH-GameThemeMusic" = {
          src = pkgs.runCommand "SDH-GameThemeMusic-1.8.2"
            {
              src = pkgs.fetchzip {
                url = "https://github.com/MegalonVII/SDH-GameThemeMusic/releases/download/1.8.2/SDH-GameThemeMusic.zip";
                sha256 = "sha256-/61RAI67Kwft8YoqGXaxYStWlWPfNHmrjTZVP8jeqao=";
                stripRoot = true;
              };
            } ''
            cp -r $src $out
            chmod -R u+w $out
            substituteInPlace $out/main.py \
              --replace-fail 'os.path.join(decky.DECKY_PLUGIN_DIR, "bin", binary)' '"${lib.getExe pkgs.yt-dlp}"' \
              --replace-fail 'f"{decky.DECKY_PLUGIN_DIR}/bin/yt-dlp",' '"${lib.getExe pkgs.yt-dlp}",' \
              --replace-fail 'os.chmod(ytdlp_path, 0o755)' 'pass'
          '';
        };
      };
    };
  };

  systemd.services.decky-loader.restartTriggers =
    lib.mapAttrsToList (_: plugin: plugin.src) config.jovian.decky-loader.plugins;
}
