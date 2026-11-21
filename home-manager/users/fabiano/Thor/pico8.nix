{ pkgs, ... }:
let
  pico8 = pkgs.callPackage ../../../../pkgs/pico8 { };
in
{
  home.packages = [ pico8 ];
}
