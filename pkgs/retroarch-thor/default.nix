{ retroarch, libretro, libretro-core-info, callPackage, symlinkJoin }:
let
  cores = with libretro; [
    melonds
    gambatte
    mgba
    ppsspp
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
    '';
  };
in
retroarch.unwrapped.wrapper {
  inherit cores;
  settings = {
    builtin_imageviewer_enable = "false";
    libretro_info_path = "${coreInfo}/share/retroarch/cores";
  };
}
