{ config, pkgs, ... }:
{
  services = {
    syncthing = {
      enable = true;
      user = "fabiano";
      configDir = "/home/fabiano/.config/syncthing";
      dataDir = "/home/fabiano/.config/syncthing/db";
      guiAddress = "0.0.0.0:8384";

      settings = {
        gui.theme = "default";

        options = {
          urAccepted = -1;
          globalAnnounceServers = ["https://syncthing-discosrv.gambiarra.net"];
          listenAddresses = [
            "quic://0.0.0.0:22000"
            "tcp://0.0.0.0:22000"
            "relay://syncthing-relaysrv.gambiarra.net:22067/?id=2UMOT3V-A523Q2O-HMCYV2Y-RV7GCXU-6G7HJ6J-FM4TXSX-JZCQOGF-MLHTLQY&networkTimeout=2m0s&pingInterval=1m0s&statusAddr=%3A22070"
          ];
        };

        devices = {
          "Syncthing Server" = { id = "5UA5VGL-USWXJUO-QQAYDXF-CQJ2ESN-AE36JZV-4GOCRIH-5I35HFQ-4O3PMAX"; addresses = [ "tcp://syncthing.gambiarra.net:22000" "relay://syncthing-relaysrv.gambiarra.net:22067/?id=2UMOT3V-A523Q2O-HMCYV2Y-RV7GCXU-6G7HJ6J-FM4TXSX-JZCQOGF-MLHTLQY&networkTimeout=2m0s&pingInterval=1m0s&statusAddr=%3A22070" ]; };
          "Odin" = { id = "ZGAPLG6-FXWLCHE-E2RMF3C-ZIYDVM2-HJDM5TO-NXDOMHW-KVFEGTM-CS2EGAK"; };
          "CrimsonTyphoon" = { id = "VT4BQGE-W2ENWSL-J7H2BDQ-D6ZCOME-G3WBEQR-P3XGIRG-T3D2ZOC-Y6FYPQI"; };
          "GipsyDanger" = { id = "6CK73B2-SHOP7QY-P7NSFET-SFP7ZYO-KTMBNJQ-QH2XKSY-VCCSPAL-UIM2KQ7"; };
          "ChernoAlpha" = { id = "RBHIV3L-FYDEZIY-3KMQQR4-65CHAME-SF7SYDV-MH6JFUK-Y2DJPKT-IEYV2AZ"; };
          "CrimsonPhoenix" = { id = "K4XUFHC-5J53HLV-N3YNAPZ-ZZRSPJL-PHNR2P3-2CVGI2O-FIP6CPF-VXFFZQG"; };
          "MiyooMiniPlus" = { id = "QAHTB2L-BWCZ323-I52LZFC-OU3U3PH-ZUKGBHS-7T3X3YY-XRBCCYB-5CFEKAO"; };
        };

        folders = {
          "[Documents] Share" = {
            enable  = true;
            path    = "/home/fabiano/Documents/Share";
            devices = [ "CrimsonTyphoon" "ChernoAlpha" "Odin" "Syncthing Server" "CrimsonPhoenix" "GipsyDanger" ];
          };

          "[Games] Game Boy Advanced Roms" = {
            enable  = true;
            path    = "/home/fabiano/Games/Roms/gba";
            devices = [ "Odin" "GipsyDanger" "MiyooMiniPlus" ];
          };
          "[Games] Super Nintendo Roms" = {
            enable  = true;
            path    = "/home/fabiano/Games/Roms/snes";
            devices = [ "Odin" "CrimsonPhoenix" "GipsyDanger" "MiyooMiniPlus" ];
          };
          "[Games] Nintendo 64 Roms" = {
            enable  = true;
            path    = "/home/fabiano/Games/Roms/n64";
            devices = [ "Odin" "GipsyDanger" ];
          };
          "[Games] Game Cube Roms" = {
            enable  = true;
            path    = "/home/fabiano/Games/Roms/gc";
            devices = [ "Odin" "GipsyDanger" ];
          };
          "[Games] Nintendo Wii Roms" = {
            enable  = true;
            path    = "/home/fabiano/Games/Roms/wii";
            devices = [ "Odin" "GipsyDanger" ];
          };
          "[Games] Nintendo Switch Roms" = {
            enable  = true;
            path    = "/home/fabiano/Games/Roms/switch";
            devices = [ "ChernoAlpha" "GipsyDanger" ];
          };
          "[Games] Playstation Roms" = {
            enable  = true;
            path    = "/home/fabiano/Games/Roms/psx";
            devices = [ "Odin" "CrimsonPhoenix" "GipsyDanger" "MiyooMiniPlus" ];
          };
          "[Games] Playstation 2 Roms" = {
            enable  = true;
            path    = "/home/fabiano/Games/Roms/ps2";
            devices = [ "Odin" "CrimsonPhoenix" "GipsyDanger" ];
          };
          "[Games] PSP Roms" = {
            enable  = true;
            path    = "/home/fabiano/Games/Roms/psp";
            devices = [ "Odin" "GipsyDanger" ];
          };
          "[Games] Saturn Roms" = {
            enable  = true;
            path    = "/home/fabiano/Games/Roms/saturn";
            devices = [ "Odin" "GipsyDanger" ];
          };
          "[Games] MAME Roms" = {
            enable  = true;
            path    = "/home/fabiano/Games/Roms/mame";
            devices = [ "Odin" "GipsyDanger" ];
          };

          "[Games] PS2 Memory cards" = {
            enable  = true;
            path    = "/home/fabiano/Games/PS2 Memory cards";
            devices = [ "Odin" "Syncthing Server" "CrimsonPhoenix" "GipsyDanger" ];
          };

          "[Games] Retroarch Saves" = {
            enable  = true;
            path    = "/home/fabiano/Games/Retroarch/Saves";
            devices = [ "Odin" "ChernoAlpha" "Syncthing Server" "CrimsonPhoenix" "GipsyDanger" "MiyooMiniPlus" ];
            versioning = { 
              type = "simple"; 
              params = { 
                keep = "10";
              }; 
            };
          };

          "[Games] Retroarch States" = {
            enable  = true;
            path    = "/home/fabiano/Games/Retroarch/States";
            devices = [ "Odin" "ChernoAlpha" "Syncthing Server" "CrimsonPhoenix" "GipsyDanger" "MiyooMiniPlus" ];
            versioning = { 
              type = "simple"; 
              params = { 
                keep = "10";
              }; 
            };
          };

          "[Games] Retroarch Runtime Logs" = {
            enable  = true;
            path    = "/home/fabiano/Games/Retroarch/Runtime logs";
            devices = [ "Odin" "ChernoAlpha" "Syncthing Server" "CrimsonPhoenix" "GipsyDanger" "MiyooMiniPlus" ];
            versioning = { 
              type = "simple"; 
              params = { 
                keep = "10";
              }; 
            };
          };

          "[Games] Retroarch System" = {
            enable  = true;
            path    = "/home/fabiano/Games/Retroarch/System";
            devices = [ "Odin" "ChernoAlpha" "Syncthing Server" "CrimsonPhoenix" "GipsyDanger" "MiyooMiniPlus" ];
            versioning = { 
              type = "simple"; 
              params = { 
                keep = "10";
              }; 
            };
          };

          "[Yuzu] Saves" = {
            enable  = true;
            path    = "/home/fabiano/.local/share/yuzu/nand/user/save";
            devices = [ "Syncthing Server" "GipsyDanger" ];
          };

          "[PCSX2] Cheats" = {
            enable  = true;
            path    = "/home/fabiano/.config/PCSX2/cheats";
            devices = [ "Syncthing Server" "GipsyDanger" ];
          };
          "[PCSX2] States" = {
            enable  = true;
            path    = "/home/fabiano/.config/PCSX2/sstates";
            devices = [ "Syncthing Server" "GipsyDanger" ];
          };
          "[PCSX2] Covers" = {
            enable  = true;
            path    = "/home/fabiano/.config/PCSX2/covers";
            devices = [ "Syncthing Server" "GipsyDanger" ];
          };

          "[Saves] Dynasty Warriors 8" = {
            enable  = true;
            path    = "/home/fabiano/.steam/steam/steamapps/compatdata/278080/pfx/drive_c/users/steamuser/Documents/TecmoKoei/Dynasty Warriors 8/Savedata";
            devices = [ "Syncthing Server" "GipsyDanger" ];
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

  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [
      { from = 22000; to = 22000; } # Syncthing
      { from = 21027; to = 21027; } # Syncthing
    ];
    allowedUDPPortRanges = [
      { from = 22000; to = 22000; } # Syncthing
      { from = 21027; to = 21027; } # Syncthing
    ];
  };
}
