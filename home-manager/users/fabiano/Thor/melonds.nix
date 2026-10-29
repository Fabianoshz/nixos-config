{ config, pkgs, lib, ... }:
let
  dataDir = "${config.xdg.dataHome}/melonDS";

  # RetroArch's hotkeys: Space, Keypad +, Keypad - (Qt key | Qt::KeypadModifier).
  hotkeys = {
    HK_FastForwardToggle = 32;
    HK_VolumeUp = 536870955;
    HK_VolumeDown = 536870957;
  };

  settings = (pkgs.formats.toml { }).generate "melonDS.toml" {
    Instance0 = {
      Keyboard = hotkeys;
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
    run ${pkgs.gawk}/bin/gawk -i inplace -v keys='${lib.concatStringsSep " " (lib.mapAttrsToList (k: v: "${k}=${toString v}") hotkeys)}' '
      BEGIN { n = split(keys, kv, " "); for (i = 1; i <= n; i++) { split(kv[i], p, "="); want[p[1]] = p[2] } }
      /^\[/ { if (insec) flush(); insec = ($0 == "[Instance0.Keyboard]") }
      insec && $1 in want { print $1 " = " want[$1]; done[$1] = 1; next }
      { print }
      END { if (insec) flush() }
      function flush(  k) { for (k in want) if (!(k in done)) print k " = " want[k]; insec = 0 }
    ' "$dir/melonDS.toml"
  '';
}
