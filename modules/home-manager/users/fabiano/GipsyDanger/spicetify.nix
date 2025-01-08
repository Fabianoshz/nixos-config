{ inputs, pkgs, ... }:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in
{
  programs.spicetify =
    {
      enable = true;
      theme = spicePkgs.themes.dribbblish;
      colorScheme = "Nord-Dark";

      enabledExtensions = with spicePkgs.extensions; [
        fullAppDisplay
        shuffle # shuffle+ (special characters are sanitized out of ext names)
        hidePodcasts
	trashbin
      ];
    };
}
