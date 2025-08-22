{ lib, system-mac, firefox-addons, ... }:
with lib;
let
  general = builtins.fromJSON (builtins.readFile ../../../../sensitive/general.json);
in
{
  programs.firefox = {
    enable = true;
    profiles.main = {
      id = 0;

      extensions = {
        packages = with firefox-addons.packages.${system-mac}; [
          keepassxc-browser
          sponsorblock
          steam-database
          ublock-origin
        ];
      };

      settings = {
	"extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
	"media.videocontrols.picture-in-picture.enabled" = false;
        "extensions.autoDisableScopes" = 0;
        "identity.fxaccounts.account.device.name" = "GipsyDanger";
      };

      search = {
        force = true;
        default = "searx";
        order = [ "searx" "google" ];
        engines = {
          "searx" = {
            urls = [{ template = "https://searx.${general.domain}/?q={searchTerms}"; }];
            icon = "https://searx.${general.domain}/static/themes/simple/img/favicon.png";
            updateInterval = 24 * 60 * 60 * 1000; # every day
          };
        };
      };
    };
  };
}

