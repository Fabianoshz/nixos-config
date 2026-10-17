{ lib, pkgs, ... }:
with lib;
let
  syncthing = builtins.fromJSON (builtins.readFile ../../../../sensitive/syncthing.json);
in
{
  services = {
    syncthing = {
      enable = true;
      guiAddress = "0.0.0.0:8384";

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
          "GipsyDanger" = syncthing.devices.GipsyDanger;
          "Syncthing Server" = syncthing.devices.SyncthingServer;
          "AYN Thor" = syncthing.devices.AYNThor; # Android
        };

        folders = {
          "[Documents] Share" = {
            enable = true;
            path = "/home/fabiano/Documents/Share";
            devices = [ "ChernoAlpha" "AYN Thor" "Syncthing Server" "CrimsonPhoenix" "GipsyDanger" ];
          };

          "[Games] Retroarch Runtime Logs" = {
            enable = true;
            path = "/home/fabiano/Games/Retroarch/Runtime logs";
            devices = [ "AYN Thor" "Syncthing Server" ];
            versioning = {
              type = "simple";
              params = {
                keep = "10";
              };
            };
          };

          "[Games] Retroarch System" = {
            enable = true;
            path = "/home/fabiano/Games/Retroarch/System";
            devices = [ "AYN Thor" "Syncthing Server" ];
            versioning = {
              type = "simple";
              params = {
                keep = "10";
              };
            };
          };

          "[Saves] Diablo II Ressurected" = {
            enable = true;
            path = "/home/fabiano/.local/share/Steam/steamapps/compatdata/2202640766/pfx/drive_c/users/steamuser/Saved Games";
            devices = [ "Syncthing Server" ];
            versioning = {
              type = "simple";
              params = {
                keep = "10";
              };
            };
          };

          "[Saves] Dynasty Warriors 8" = {
            enable = true;
            path = "/home/fabiano/.local/share/Steam/steamapps/compatdata/278080/pfx/drive_c/users/steamuser/Documents/TecmoKoei/Dynasty Warriors 8/Savedata";
            devices = [ "Syncthing Server" ];
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
