{ lib, pkgs, config, ... }:
with lib;
let
  syncthing = builtins.fromJSON (builtins.readFile ../../../../sensitive/syncthing.json);
in
{
  services = {
    syncthing = {
      enable = true;
      guiAddress = "0.0.0.0:8384";
      extraOptions = [ "-no-default-folder" ];

      settings = {
        gui.theme = "default";

        options = {
          urAccepted = -1;
          globalAnnounceServers = syncthing.options.globalAnnounceServers;
          listenAddresses = syncthing.options.listenAddresses;
        };

        devices = {
          "ChernoAlpha" = syncthing.devices.ChernoAlpha;
          "CrimsonTyphoon" = syncthing.devices.CrimsonTyphoon;
          "GipsyAvenger" = syncthing.devices.GipsyAvenger;
          "GipsyDanger" = syncthing.devices.GipsyDanger;
          "MiyooMiniPlus" = syncthing.devices.MiyooMiniPlus;
          "Odin" = syncthing.devices.Odin;
          "Syncthing Server" = syncthing.devices.SyncthingServer;
        };

        folders = {
          "[Documents] Common" = {
            enable = true;
            path = "${config.home.homeDirectory}/Documents/Common";
            devices = [ "CrimsonTyphoon" "ChernoAlpha" "Syncthing Server" "GipsyDanger" ];
          };
          "[Documents] Passwords" = {
            enable = true;
            path = "${config.home.homeDirectory}/Documents/Passwords";
            devices = [ "CrimsonTyphoon" "ChernoAlpha" "Syncthing Server" "GipsyDanger" ];
          };
          "[Documents] Share" = {
            enable = true;
            path = "${config.home.homeDirectory}/Documents/Share";
            devices = [ "CrimsonTyphoon" "ChernoAlpha" "Odin" "Syncthing Server" "GipsyDanger" "GipsyAvenger" ];
          };
          "[Documents] Workspaces" = {
            enable = true;
            path = "${config.home.homeDirectory}/Documents/Workspaces";
            devices = [ "Syncthing Server" "GipsyDanger" ];
          };

          "[Media] Music" = {
            enable = true;
            path = "${config.home.homeDirectory}/Music";
            devices = [ "GipsyDanger" "GipsyAvenger" "ChernoAlpha" "Odin" ];
          };
        };
      };
    };
  };
}
