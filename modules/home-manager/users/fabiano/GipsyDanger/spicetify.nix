{ inputs, pkgs, ... }:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in
{
  programs.spicetify =
    {
      enable = true;
      theme = spicePkgs.themes.ziro;
      colorScheme = "Gray-Dark";

      enabledExtensions = with spicePkgs.extensions; [
        fullAppDisplay
        shuffle # shuffle+ (special characters are sanitized out of ext names)
        hidePodcasts
	trashbin
      ];
    };
}
