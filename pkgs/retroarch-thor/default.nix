{ lib, path, libretro, libretro-core-info, retroarch-assets, retroarch-joypad-autoconfig, makeBinaryWrapper, writeText, callPackage, symlinkJoin }:
let
  cores = with libretro; [
    gambatte
    mgba
    ppsspp
    (callPackage ../libretro-melonds-ds { })
    (callPackage ../libretro-fake08 { })
    (callPackage ../libretro-azahar { })
    (callPackage ../libretro-vita3k { })
  ];

  coreInfo = symlinkJoin {
    name = "retroarch-thor-core-info";
    paths = [ libretro-core-info ] ++ cores;
    postBuild = ''
      mkdir -p $out/share/retroarch/cores
      for f in $out/lib/retroarch/cores/*.info; do
        [ -e "$f" ] && ln -sf "$(readlink -f "$f")" $out/share/retroarch/cores/
      done
      info=$out/share/retroarch/cores/azahar_libretro.info
      src=$(readlink -f "$info")
      rm "$info"
      sed 's/^supported_extensions = .*/supported_extensions = "3ds|3dsx|z3dsx|elf|axf|cci|zcci|cxi|zcxi|app"/' "$src" > "$info"
    '';
  };
in
import (path + "/pkgs/by-name/re/retroarch-bare/wrapper.nix") {
  inherit lib libretro makeBinaryWrapper writeText symlinkJoin cores;
  retroarch-bare = callPackage ./bare.nix { };
  settings = {
    assets_directory = "${retroarch-assets}/share/retroarch/assets";
    joypad_autoconfig_dir = "${retroarch-joypad-autoconfig}/share/libretro/autoconfig";
    builtin_imageviewer_enable = "false";
    libretro_info_path = "${coreInfo}/share/retroarch/cores";
    video_windows_enable = "true";
  };
}
