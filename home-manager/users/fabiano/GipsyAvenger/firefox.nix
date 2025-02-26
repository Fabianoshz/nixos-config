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
        "extensions.autoDisableScopes" = 0;
      };
    };
  };
}

