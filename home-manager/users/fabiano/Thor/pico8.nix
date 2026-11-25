{ pkgs, config, ... }:
let
  pico8 = pkgs.callPackage ../../../../pkgs/pico8 { };
in
{
  home.packages = [ pico8 ];

  xdg.desktopEntries.pico8 = {
    name = "PICO-8";
    comment = "Fantasy console";
    exec = "pico8";
    icon = "${config.home.homeDirectory}/Games/pico-8/lexaloffle-pico8.png";
    terminal = false;
    categories = [ "Game" ];
  };
}
