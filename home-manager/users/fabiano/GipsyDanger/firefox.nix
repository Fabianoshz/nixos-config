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
        packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
          consent-o-matic
          keepassxc-browser
          sponsorblock
          steam-database
          ublock-origin
        ];
      };

      settings = {
        "browser.ml.chat.enabled" = false;
        "browser.ml.chat.menu" = false;
        "browser.ml.chat.page" = false;
        "browser.ml.chat.sidebar" = false;
        "browser.ml.enable" = false;
        "browser.ml.linkPreview.enabled" = false;
        "browser.newtabpage.pinned" = "";
        "browser.startup.page" = 3;
        "browser.tabs.groups.smart.enabled" = false;
        "browser.tabs.groups.smart.userEnabled" = false;
        "browser.toolbars.bookmarks.visibility" = "never";
        "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
        "extensions.autoDisableScopes" = 0;
        "identity.fxaccounts.account.device.name" = "GipsyDanger";
        "media.videocontrols.picture-in-picture.enabled" = false;
        "pdfjs.enableAltTextModelDownload" = false;
        "pdfjs.enableGuessAltText" = false;
        "widget.use-xdg-desktop-portal.file-picker" = 1;
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
