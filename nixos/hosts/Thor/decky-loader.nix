{ config, pkgs, lib, inputs, ... }:
let
  retroarchWithCores = pkgs.callPackage ../../../pkgs/retroarch-thor { };

  melonds-dual = pkgs.writeShellScript "melonds-dual" ''
    exec ${pkgs.melonds}/bin/melonDS -f -stylesheet "$HOME/.config/melonDS/hide-menubar.qss" "$@"
  '';

  home = config.users.users.fabiano.home;

  romm-tender = pkgs.callPackage ../../../pkgs/romm-tender {
    retroarch = retroarchWithCores;
    coreFor = with pkgs.libretro; {
      gb = gambatte;
      gbc = gambatte;
      gba = mgba;
      psp = ppsspp;
    };
    standaloneSaves = {
      nds = {
        emulator = "melonDS";
        dir = "${home}/.local/share/melonDS/saves";
        ext = ".sav";
        serverExt = ".srm";
      };
      psp = {
        emulator = "PPSSPP";
        dir = "${home}/Games/Retroarch/Saves/PPSSPP/PSP/SAVEDATA";
        stage = "${home}/.local/share/romm-tender/folder-saves/psp";
        layout = "psp-savedata";
      };
      n3ds = {
        emulator = "Azahar";
        dir = "${home}/.local/share/azahar-emu/sdmc/Nintendo 3DS/00000000000000000000000000000000/00000000000000000000000000000000/title";
        stage = "${home}/.local/share/romm-tender/folder-saves/n3ds";
        layout = "3ds-title";
      };
    };
    standalone = {
      nds = melonds-dual;
      n3ds = "${pkgs.azahar}/bin/azahar -f";
    };
  };
in
{
  imports = [
    "${inputs.jovian-nixos}/modules/decky-loader.nix"
    ../../optional/decky-loader/default.nix
  ];

  jovian.decky-loader = {
    enable = true;
    user = "fabiano";
    package = pkgs.callPackage "${inputs.jovian-nixos}/pkgs/decky-loader/stable.nix" { };

    extraPackages = [
      pkgs.curl
      pkgs.ffmpeg # For GameThemeMusic plugin
      pkgs.python3
    ];
    extraPythonPackages = pythonPackages: [
      pythonPackages.hid
    ];

    # Got from: https://plugins.deckbrew.xyz/plugins
    plugins = {
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
          url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/99beaf1374af82408e6d056e0b0147e5fca544e1035fa7ab88419231697bc231.zip";
          sha256 = "sha256-u/mVSepDeydS3j0GZ1H+r4kyQMwIRuPKaRy7eaerIKg=";
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

  systemd.services.decky-loader.restartTriggers =
    lib.mapAttrsToList (_: plugin: plugin.src) config.jovian.decky-loader.plugins;
}
