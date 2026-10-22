{ pkgs, lib, ... }:
let
  guid = "030079f6de280000ff11000001000000";
  sdl = params: ''"${params},engine:sdl,guid:${guid},port:0"'';
  button = n: sdl "button:${toString n}";
  hat = dir: sdl "direction:${dir},hat:0";
  trigger = axis: sdl "axis:${toString axis},direction:+,threshold:0.5";
  stick = x: y: sdl "axis_x:${toString x},axis_y:${toString y},deadzone:0.100000";

  config = pkgs.writeText "qt-config.ini" ''
    [Layout]
    layout_option=4

    [Controls]
    profile=0
    profiles\1\name=Default
    profiles\1\button_a=${button 1}
    profiles\1\button_b=${button 0}
    profiles\1\button_x=${button 3}
    profiles\1\button_y=${button 2}
    profiles\1\button_up=${hat "up"}
    profiles\1\button_down=${hat "down"}
    profiles\1\button_left=${hat "left"}
    profiles\1\button_right=${hat "right"}
    profiles\1\button_l=${button 4}
    profiles\1\button_r=${button 5}
    profiles\1\button_start=${button 7}
    profiles\1\button_select=${button 6}
    profiles\1\button_zl=${trigger 2}
    profiles\1\button_zr=${trigger 5}
    profiles\1\circle_pad=${stick 0 1}
    profiles\1\c_stick=${stick 3 4}
    profiles\size=1
  '';
in
{
  home.packages = [ pkgs.azahar ];

  home.activation.azaharSeed = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    dir="$HOME/.config/azahar-emu"
    run mkdir -p "$dir"
    [ -e "$dir/qt-config.ini" ] || run install -m 644 ${config} "$dir/qt-config.ini"
  '';
}
