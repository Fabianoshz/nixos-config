{ pkgs, lib, ... }:
let
  config = pkgs.writeText "retroarch.cfg" ''
    savefile_directory = "~/Games/Retroarch/Saves"
    savestate_directory = "~/Games/Retroarch/States"
    system_directory = "~/Games/Retroarch/System"
    sort_savefiles_enable = "true"
    sort_savefiles_by_content_enable = "false"
    sort_savestates_enable = "true"
    sort_savestates_by_content_enable = "false"
    video_fullscreen = "true"
    input_joypad_driver = "sdl2"
    video_context_driver = "x"
  '';

  retroarchWithCores = pkgs.callPackage ../../../../pkgs/retroarch-thor { };
in
{
  home.packages = [ retroarchWithCores ];

  home.activation.retroarchSeed = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    dir="$HOME/.config/retroarch"
    run mkdir -p "$dir" "$HOME/Games/Retroarch/Saves" "$HOME/Games/Retroarch/States" "$HOME/Games/Retroarch/System"
    [ -e "$dir/retroarch.cfg" ] || run install -m 644 ${config} "$dir/retroarch.cfg"
  '';
}
