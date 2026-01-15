{ lib, inputs, pkgs, ... }:
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
        packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
          keepassxc-browser
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
