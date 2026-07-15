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
          "CrimsonTyphoon" = syncthing.devices.CrimsonTyphoon;
          "GipsyAvenger" = syncthing.devices.GipsyAvenger;
          "GipsyDanger" = syncthing.devices.GipsyDanger;
          "Syncthing Server" = syncthing.devices.SyncthingServer;
        };

        folders = {
          "[Documents] Share" = {
            enable = true;
            path = "/home/fabiano/Documents/Share";
            devices = [ "CrimsonTyphoon" "ChernoAlpha" "Syncthing Server" "CrimsonPhoenix" "GipsyDanger" ];
          };

          "[Media] Music" = {
            enable = true;
            path = "/home/fabiano/Music";
            devices = [ "CrimsonPhoenix" "ChernoAlpha" "GipsyDanger" ];
          };

          "[Games] Retroarch Saves" = {
            enable = true;
            path = "/home/fabiano/Games/Retroarch/Saves";
            devices = [ "Syncthing Server" ];
            versioning = {
              type = "simple";
              params = {
                keep = "10";
              };
            };
          };

          "[Games] Retroarch States" = {
            enable = true;
            path = "/home/fabiano/Games/Retroarch/States";
            devices = [ "Syncthing Server" ];
            versioning = {
              type = "simple";
              params = {
                keep = "10";
              };
            };
          };

          "[Games] Retroarch Runtime Logs" = {
            enable = true;
            path = "/home/fabiano/Games/Retroarch/Runtime logs";
            devices = [ "Syncthing Server" ];
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
