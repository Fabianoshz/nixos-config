{ system-mac, firefox-addons, ... }:
{
  programs.firefox = {
    enable = true;
    profiles.main = {
      id = 0;

      extensions = {
        packages = with firefox-addons.packages.${system-mac}; [
          sponsorblock
          ublock-origin
          steam-database
          add-custom-search-engine
          keepassxc-browser
        ];
      };

      settings = {
	"identity.fxaccounts.account.device.name" = "CrimsonPhoenix";
        "extensions.autoDisableScopes" = 0;
	"media.videocontrols.picture-in-picture.enabled" = false;
      };
    };
  };
}

