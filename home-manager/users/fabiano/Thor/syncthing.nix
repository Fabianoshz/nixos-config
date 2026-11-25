{ lib, pkgs, ... }:
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
          "GipsyAvenger" = syncthing.devices.GipsyAvenger;
          "GipsyDanger" = syncthing.devices.GipsyDanger;
          "Syncthing Server" = syncthing.devices.SyncthingServer;
          "Shield Sala" = syncthing.devices.ShieldSala;
          "Shield Suíte" = syncthing.devices.ShieldSuite;
        };

        folders = {
          "[Documents] Share" = {
            enable = true;
            path = "/home/fabiano/Documents/Share";
            devices = [ "ChernoAlpha" "Syncthing Server" "CrimsonPhoenix" "GipsyDanger" "GipsyAvenger" "Shield Sala" "Shield Suíte" ];
          };

          "[Games] Retroarch Runtime Logs" = {
            enable = true;
            path = "/home/fabiano/Games/Retroarch/Runtime logs";
            devices = [ "Syncthing Server" "GipsyAvenger" "Shield Sala" "Shield Suíte" ];
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
            devices = [ "Syncthing Server" "GipsyAvenger" "Shield Sala" "Shield Suíte" ];
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
