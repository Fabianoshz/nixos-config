{ lib, inputs, pkgs, ... }:
with lib;
let
  general = builtins.fromJSON (builtins.readFile ../../../../sensitive/general.json);
in
{
  programs.firefox = {
    enable = true;
    nativeMessagingHosts = [ pkgs.kdePackages.plasma-browser-integration ];
    profiles.main = {
      id = 0;

      extensions = {
        packages = with inputs.firefox-addons.packages.${pkgs.system}; [
          sponsorblock
          steam-database
          ublock-origin
        ];
      };

      settings = {
        "browser.newtabpage.pinned" = "";
        "browser.startup.page" = 3;
        "browser.toolbars.bookmarks.visibility" = "never";
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "extensions.activethemeid" = "firefox-compact-dark@mozilla.org";
        "extensions.autodisablescopes" = 0;
        "identity.fxaccounts.account.device.name" = "gipsydanger";
        "media.videocontrols.picture-in-picture.enabled" = false;
      };
    };

    profiles.youtube = {
      id = 1;

      extensions = {
        packages = with inputs.firefox-addons.packages.${pkgs.system}; [
          sponsorblock
          ublock-origin
        ];
      };

      settings = {
        "identity.fxaccounts.account.device.name" = "GipsyAvenger-Youtube";
        "general.useragent.override" = "Mozilla/5.0 (Linux; Android 12) Cobalt/22.2.3-gold (PS4)";
        "media.eme.enabled" = true;
        "media.gmp-widevinecdm.enabled" = true;
        "media.gmp-widevinecdm.autoupdate" = true;
        "media.videocontrols.picture-in-picture.enabled" = false;
        "extensions.autoDisableScopes" = 0;
        "extensions.enabledScopes" = 15;
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
