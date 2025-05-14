{ system, firefox-addons, ... }:
{
  programs.firefox = {
    enable = true;
    profiles.main = {
      id = 0;

      extensions = {
	packages = with firefox-addons.packages.${system}; [
          sponsorblock
          ublock-origin
        ];
      };

      settings = {
	"identity.fxaccounts.account.device.name" = "GipsyAvenger";
        "extensions.autoDisableScopes" = 0;
	"media.videocontrols.picture-in-picture.enabled" = false;
      };
    };

    profiles.youtube = {
      id = 1;

      extensions = {
	packages = with firefox-addons.packages.${system}; [
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
    };
  };
}

