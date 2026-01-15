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
          "GipsyDanger" = syncthing.devices.GipsyDanger;
          "MiyooMiniPlus" = syncthing.devices.MiyooMiniPlus;
          "Odin" = syncthing.devices.Odin;
          "Syncthing Server" = syncthing.devices.SyncthingServer;
          "Thor" = syncthing.devices.Thor;
        };

        folders = {
          "[Documents] Share" = {
            enable = true;
            path = "/home/fabiano/Documents/Share";
            devices = [ "CrimsonTyphoon" "ChernoAlpha" "Odin" "Thor" "Syncthing Server" "CrimsonPhoenix" "GipsyDanger" ];
          };

          "[Media] Music" = {
            enable = true;
            path = "/home/fabiano/Music";
            devices = [ "CrimsonPhoenix" "ChernoAlpha" "Odin" "Thor" "GipsyDanger" ];
          };

          "[Games] PS2 Memory cards" = {
            enable = true;
            path = "/home/fabiano/Games/PS2 Memory cards";
            devices = [ "Syncthing Server" ];
          };

          "[Games] Retroarch Saves" = {
            enable = true;
            path = "/home/fabiano/Games/Retroarch/Saves";
            devices = [ "Odin" "Thor" "Syncthing Server" "MiyooMiniPlus" ];
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
            devices = [ "Odin" "Thor" "Syncthing Server" "MiyooMiniPlus" ];
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
            devices = [ "Odin" "Thor" "Syncthing Server" "MiyooMiniPlus" ];
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
            devices = [ "Odin" "Thor" "Syncthing Server" "MiyooMiniPlus" ];
            versioning = {
              type = "simple";
              params = {
                keep = "10";
              };
            };
          };

          "[Yuzu] Saves" = {
            enable = true;
            path = "/home/fabiano/.local/share/yuzu/nand/user/save";
            devices = [ "Syncthing Server" ];
          };

          "[PCSX2] Cheats" = {
            enable = true;
            path = "/home/fabiano/.config/PCSX2/cheats";
            devices = [ "Syncthing Server" ];
          };
          "[PCSX2] States" = {
            enable = true;
            path = "/home/fabiano/.config/PCSX2/sstates";
            devices = [ "Syncthing Server" ];
          };
          "[PCSX2] Covers" = {
            enable = true;
            path = "/home/fabiano/.config/PCSX2/covers";
            devices = [ "Syncthing Server" ];
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
            path = "/home/fabiano/.local/share/Steam/steamapps/compatdata/2202640766/pfx/drive_c/users/steamuser/Saved Games/Diablo II Resurrected";
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
