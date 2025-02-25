{
  services = {
    syncthing = {
      enable = true;
      guiAddress = "127.0.0.1:8384";
      extraOptions = ["-no-default-folder"];

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
          "GipsyAvenger" = { id = "YKYSHGV-2AR2QWG-HURFZNW-ECLBSM2-KWH4RZQ-O4Z5LHQ-I74GMP2-Q2JP7AS"; };
          "ChernoAlpha" = { id = "RBHIV3L-FYDEZIY-3KMQQR4-65CHAME-SF7SYDV-MH6JFUK-Y2DJPKT-IEYV2AZ"; };
          "CrimsonPhoenix" = { id = "SR6GM2J-22RQ2TN-HGA3EHE-Z72N4EP-6SFWDTN-R7QQ72I-KU5ZF6A-DESVFAN"; };
          "MiyooMiniPlus" = { id = "QAHTB2L-BWCZ323-I52LZFC-OU3U3PH-ZUKGBHS-7T3X3YY-XRBCCYB-5CFEKAO"; };
        };

        folders = {
          "[Documents] Common" = {
            enable  = true;
            path    = "/home/fabiano/Documents/Common";
            devices = [ "CrimsonTyphoon" "ChernoAlpha" "Syncthing Server" "CrimsonPhoenix" ];
          };
          "[Documents] Passwords" = {
            enable  = true;
            path    = "/home/fabiano/Documents/Passwords";
            devices = [ "CrimsonTyphoon" "ChernoAlpha" "Syncthing Server" "CrimsonPhoenix" ];
          };
          "[Documents] Share" = {
            enable  = true;
            path    = "/home/fabiano/Documents/Share";
            devices = [ "CrimsonTyphoon" "ChernoAlpha" "Odin" "Syncthing Server" "CrimsonPhoenix" "GipsyAvenger" ];
          };
          "[Documents] Workspaces" = {
            enable  = true;
            path    = "/home/fabiano/Documents/Workspaces";
            devices = [ "Syncthing Server" "CrimsonPhoenix" ];
          };

          "[Yuzu] Saves" = {
            enable  = true;
            path    = "/home/fabiano/.local/share/yuzu/nand/user/save";
            devices = [ "Syncthing Server" "GipsyAvenger" ];
          };

          "[Saves] Diablo II Ressurected" = {
            enable  = true;
            path    = "/home/fabiano/.local/share/Steam/steamapps/compatdata/2202640766/pfx/drive_c/users/steamuser/Saved Games";
            devices = [ "Syncthing Server" "GipsyAvenger" ];
            versioning = {
              type = "simple";
              params = {
                keep = "10";
              };
            };
          };

          "[Saves] Dynasty Warriors 8" = {
            enable  = true;
            path    = "/home/fabiano/.steam/steam/steamapps/compatdata/278080/pfx/drive_c/users/steamuser/Documents/TecmoKoei/Dynasty Warriors 8/Savedata";
            devices = [ "Syncthing Server" "GipsyAvenger" ];
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
