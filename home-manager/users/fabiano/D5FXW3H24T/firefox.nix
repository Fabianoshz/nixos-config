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
          steam-database
          add-custom-search-engine
          keepassxc-browser
        ];
      };

      settings = {
        "extensions.autoDisableScopes" = 0;
      };
    };
  };
}

