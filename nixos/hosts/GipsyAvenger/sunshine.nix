{ pkgs, config, lib, ... }:
let
  sunshine-steam-sync = pkgs.callPackage ../../../pkgs/sunshine-steam-sync { };

  # Reference the same apps file that sunshine module generates
  appsFormat = pkgs.formats.json { };
  staticAppsFile = appsFormat.generate "apps.json" config.services.sunshine.applications;

  # Load SteamGridDB API key from sensitive file
  steamgriddb = builtins.fromJSON (builtins.readFile ../../../sensitive/steamgriddb.json);
in
{
  services = {
    sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
      settings = {
        back_button_timeout = 2000;
        # Point to merged apps file in user's home directory
        file_apps = lib.mkForce "/home/fabiano/.config/sunshine/apps.json";
      };
      applications = {
        env = {
          PATH = "$(PATH):$(HOME)/.local/bin:${sunshine-steam-sync}/bin";
        };
        apps = [
          {
            name = "Desktop";
          }
        ];
      };
    };
  };

  systemd.user.services.sunshine-steam-sync = {
    description = "Sync Steam games to Sunshine apps configuration";

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${sunshine-steam-sync}/bin/sunshine-steam-sync";
    };

    environment = {
      SUNSHINE_STATIC_APPS = "${staticAppsFile}";
      SUNSHINE_APPS_OUTPUT = "/home/fabiano/.config/sunshine/apps.json";
      STEAMGRIDDB_API_KEY = steamgriddb.api_key;
    };
  };

  systemd.user.timers.sunshine-steam-sync = {
    description = "Periodically sync Steam games to Sunshine";
    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "1h";
      Unit = "sunshine-steam-sync.service";
    };
  };

  systemd.user.services.sunshine-game-launcher = {
    description = "Sunshine game launcher daemon";
    wantedBy = [ "default.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${sunshine-steam-sync}/bin/sunshine-game-launcher";
      Restart = "on-failure";
      RestartSec = "5s";
    };

    environment = {
      PATH = lib.mkForce "/run/current-system/sw/bin:/home/fabiano/.local/bin";
    };
  };
}
