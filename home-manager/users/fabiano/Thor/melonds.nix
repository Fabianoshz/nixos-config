{ config, pkgs, lib, ... }:
let
  dataDir = "${config.xdg.dataHome}/melonDS";

  settings = (pkgs.formats.toml { }).generate "melonDS.toml" {
    Instance0 = {
      SaveFilePath = "${dataDir}/saves";
      SavestatePath = "${dataDir}/states";
      Window0.ScreenSizing = 4;
      Window1 = {
        Enabled = true;
        ScreenSizing = 5;
      };
      Joystick = {
        A = 1;
        B = 0;
        X = 3;
        Y = 2;
        L = 4;
        R = 5;
        Select = 6;
        Start = 7;
        Up = 257;
        Right = 258;
        Down = 260;
        Left = 264;
      };
    };
  };

  stylesheet = pkgs.writeText "hide-menubar.qss" ''
    QMenuBar { max-height: 0px; min-height: 0px; height: 0px; border: none; padding: 0px; }
    QMenuBar::item { padding: 0px; }
  '';
in
{
  home.packages = [ pkgs.melonds ];

  home.activation.melondsSeed = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    dir="$HOME/.config/melonDS"
    run mkdir -p "$dir" "${dataDir}/saves" "${dataDir}/states"
    [ -e "$dir/melonDS.toml" ] || run install -m 644 ${settings} "$dir/melonDS.toml"
    [ -e "$dir/hide-menubar.qss" ] || run install -m 644 ${stylesheet} "$dir/hide-menubar.qss"
  '';
}
