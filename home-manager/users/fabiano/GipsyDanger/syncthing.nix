{ lib, pkgs, config, ... }:
with lib;
let
  syncthing = builtins.fromJSON (builtins.readFile ../../../../sensitive/syncthing.json);
in
{
  home.file = {
    # Ignore Obsidian files
    "${config.home.homeDirectory}/Documents/General/.stignore" = {
      text = "Obsidian/*/.obsidian/**";
      executable = false;
    };
  };

  services = {
    syncthing = {
      enable = true;
      guiAddress = "127.0.0.1:8384";

      settings = {
        gui.theme = "default";

        options = {
          urAccepted = -1;
          globalAnnounceServers = syncthing.options.globalAnnounceServers;
          listenAddresses = syncthing.options.listenAddresses;
        };

        devices = {
          "Thor" = syncthing.devices.Thor;
          "ChernoAlpha" = syncthing.devices.ChernoAlpha;
          "CrimsonPhoenix" = syncthing.devices.CrimsonPhoenix;
          "GipsyAvenger" = syncthing.devices.GipsyAvenger;
          "Syncthing Server" = syncthing.devices.SyncthingServer;
        };

        folders = {
          "[Documents] General" = {
            enable = true;
            path = "${config.home.homeDirectory}/Documents/General";
            devices = [ "ChernoAlpha" "Syncthing Server" "CrimsonPhoenix" ];
            versioning = {
              type = "simple";
              params.keep = "10";
            };
          };
          "[Documents] Passwords" = {
            enable = true;
            path = "${config.home.homeDirectory}/Documents/Passwords";
            devices = [ "ChernoAlpha" "Syncthing Server" "CrimsonPhoenix" ];
          };
          "[Documents] Share" = {
            enable = true;
            path = "${config.home.homeDirectory}/Documents/Share";
            devices = [ "ChernoAlpha" "Thor" "Syncthing Server" "CrimsonPhoenix" "GipsyAvenger" ];
          };
          "[Documents] Workspaces" = {
            enable = true;
            path = "${config.home.homeDirectory}/Documents/Workspaces";
            devices = [ "Syncthing Server" "CrimsonPhoenix" ];
          };
        };
      };
    };
  };
}
