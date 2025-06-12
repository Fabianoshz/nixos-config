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
      extraOptions = ["-no-default-folder"];

      settings = {
        gui.theme = "default";

        options = {
          urAccepted = -1;
          globalAnnounceServers = syncthing.options.globalAnnounceServers;
          listenAddresses = syncthing.options.listenAddresses;
        };

        devices = {
          "Syncthing Server" = syncthing.devices.SyncthingServer;
          "Odin" = syncthing.devices.Odin;
          "CrimsonTyphoon" = syncthing.devices.CrimsonTyphoon;
          "GipsyDanger" = syncthing.devices.GipsyDanger;
          "ChernoAlpha" = syncthing.devices.ChernoAlpha;
          "GipsyAvenger" = syncthing.devices.GipsyAvenger;
          "MiyooMiniPlus" = syncthing.devices.MiyooMiniPlus;
	};

        folders = {
          "[Documents] Common" = {
            enable  = true;
            path    = "/Users/fabiano/Documents/Common";
            devices = [ "CrimsonTyphoon" "ChernoAlpha" "Syncthing Server" "GipsyDanger" ];
          };
          "[Documents] Passwords" = {
            enable  = true;
            path    = "/Users/fabiano/Documents/Passwords";
            devices = [ "CrimsonTyphoon" "ChernoAlpha" "Syncthing Server" "GipsyDanger" ];
          };
          "[Documents] Share" = {
            enable  = true;
            path    = "/Users/fabiano/Documents/Share";
            devices = [ "CrimsonTyphoon" "ChernoAlpha" "Odin" "Syncthing Server" "GipsyDanger" "GipsyAvenger" ];
          };
          "[Documents] Workspaces" = {
            enable  = true;
            path    = "/Users/fabiano/Documents/Workspaces";
            devices = [ "Syncthing Server" "GipsyDanger" ];
          };

          "[Media] Music" = {
            enable  = true;
            path    = "/Users/fabiano/Music";
            devices = [ "GipsyDanger" "ChernoAlpha" "Odin" ];
          };
        };
      };
    };
  };
}
