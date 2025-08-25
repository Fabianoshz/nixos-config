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
          "GipsyDanger" = syncthing.devices.GipsyDanger;
        };

        folders = {
          "[Media] Music" = {
            enable = true;
            path = "/Users/fabiano/Music";
            devices = [ "GipsyDanger" "ChernoAlpha" "CrimsonTyphoon" ];
          };
        };
      };
    };
  };
}
