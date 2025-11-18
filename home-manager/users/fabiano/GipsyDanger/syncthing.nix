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
          "ChernoAlpha" = syncthing.devices.ChernoAlpha;
          "CrimsonPhoenix" = syncthing.devices.CrimsonPhoenix;
          "CrimsonTyphoon" = syncthing.devices.CrimsonTyphoon;
          "GipsyAvenger" = syncthing.devices.GipsyAvenger;
          "MiyooMiniPlus" = syncthing.devices.MiyooMiniPlus;
          "Odin" = syncthing.devices.Odin;
          "Syncthing Server" = syncthing.devices.SyncthingServer;
        };

        folders = {
          "[Documents] General" = {
            enable = true;
            path = "${config.home.homeDirectory}/Documents/General";
            devices = [ "CrimsonTyphoon" "ChernoAlpha" "Syncthing Server" "CrimsonPhoenix" ];
            versioning = {
              type = "simple";
              params.keep = "10";
            };
          };
          "[Documents] Passwords" = {
            enable = true;
            path = "${config.home.homeDirectory}/Documents/Passwords";
            devices = [ "CrimsonTyphoon" "ChernoAlpha" "Syncthing Server" "CrimsonPhoenix" ];
          };
          "[Documents] Share" = {
            enable = true;
            path = "${config.home.homeDirectory}/Documents/Share";
            devices = [ "CrimsonTyphoon" "ChernoAlpha" "Odin" "Syncthing Server" "CrimsonPhoenix" "GipsyAvenger" ];
          };
          "[Documents] Workspaces" = {
            enable = true;
            path = "${config.home.homeDirectory}/Documents/Workspaces";
            devices = [ "Syncthing Server" "CrimsonPhoenix" ];
          };

          "[Media] Music" = {
            enable = true;
            path = "${config.home.homeDirectory}/Music";
            devices = [ "CrimsonPhoenix" "ChernoAlpha" "Odin" "GipsyAvenger" ];
          };
        };
      };
    };
  };
}
