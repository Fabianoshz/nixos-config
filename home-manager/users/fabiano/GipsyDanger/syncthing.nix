{ lib, pkgs, ... }:
with lib;
let
  syncthing = builtins.fromJSON (builtins.readFile ../../../../sensitive/syncthing.json);
in
{
  services = {
    syncthing = {
      enable = true;
      guiAddress = "127.0.0.1:8384";
      extraOptions = ["-no-default-folder"];

      settings = {
        gui.theme = "default";

        options = {
          urAccepted = -1;
          globalAnnounceServers = syncthing.options.globalAnnounceServers;
          listenAddresses = syncthing.options.listenAddresses;
        };

        devices = {
          "ChernoAlpha" = syncthing.devices.ChernoAlpha;
          "CrimsonPhoenix" = syncthing.devices.CrimsonPhoenix;
          "CrimsonTyphoon" = syncthing.devices.CrimsonTyphoon;
          "GipsyAvenger" = syncthing.devices.GipsyAvenger;
          "MiyooMiniPlus" = syncthing.devices.MiyooMiniPlus;
          "Odin" = syncthing.devices.Odin;
          "Syncthing Server" = syncthing.devices.SyncthingServer;
	};

        folders = {
          "[Documents] Common" = {
            enable  = true;
            path    = "/home/fabiano/Documents/Common";
            devices = [ "CrimsonTyphoon" "ChernoAlpha" "Syncthing Server" "CrimsonPhoenix" ];
          };
          "[Documents] Passwords" = {
            enable  = true;
            path    = "/home/fabiano/Documents/Passwords";
            devices = [ "CrimsonTyphoon" "ChernoAlpha" "Syncthing Server" "CrimsonPhoenix" ];
          };
          "[Documents] Share" = {
            enable  = true;
            path    = "/home/fabiano/Documents/Share";
            devices = [ "CrimsonTyphoon" "ChernoAlpha" "Odin" "Syncthing Server" "CrimsonPhoenix" "GipsyAvenger" ];
          };
          "[Documents] Workspaces" = {
            enable  = true;
            path    = "/home/fabiano/Documents/Workspaces";
            devices = [ "Syncthing Server" "CrimsonPhoenix" ];
          };

          "[Media] Music" = {
            enable  = true;
            path    = "/home/fabiano/Music";
            devices = [ "CrimsonPhoenix" "ChernoAlpha" "Odin" ];
          };

          "[Yuzu] Saves" = {
            enable  = true;
            path    = "/home/fabiano/.local/share/yuzu/nand/user/save";
            devices = [ "Syncthing Server" "GipsyAvenger" ];
          };

          "[Saves] Diablo II Ressurected" = {
            enable  = true;
            path    = "/home/fabiano/.local/share/Steam/steamapps/compatdata/2202640766/pfx/drive_c/users/steamuser/Saved Games";
            devices = [ "Syncthing Server" "GipsyAvenger" ];
            versioning = {
              type = "simple";
              params = {
                keep = "10";
              };
            };
          };

          "[Saves] Dynasty Warriors 8" = {
            enable  = true;
            path    = "/home/fabiano/.steam/steam/steamapps/compatdata/278080/pfx/drive_c/users/steamuser/Documents/TecmoKoei/Dynasty Warriors 8/Savedata";
            devices = [ "Syncthing Server" "GipsyAvenger" ];
            versioning = {
              type = "simple";
              params = {
                keep = "10";
              };
            };
          };
        };
      };
    };
  };
}
