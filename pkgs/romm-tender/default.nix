# Tender (romm-tender) 0.33.0, patched to run without RetroDECK:
# games launch in Nix RetroArch, ROMs live in ~/Games/Roms/<system>.
{ lib
, stdenv
, runCommand
, fetchurl
, fetchFromGitHub
, unzip
, writeShellScript
, writeText
, libretro
, libretro-core-info
, retroarch
  # Tender system folder -> libretro core. Every core must be in `retroarch.cores`.
, coreFor ? with libretro; {
    snes = snes9x;
    sfc = snes9x;
    n64 = mupen64plus;
    genesis = genesis-plus-gx;
    megadrive = genesis-plus-gx;
    mastersystem = genesis-plus-gx;
    gamegear = genesis-plus-gx;
    segacd = genesis-plus-gx;
    megacd = genesis-plus-gx;
    psx = beetle-psx-hw;
    saturn = beetle-saturn;
    ps2 = pcsx2;
    gc = dolphin;
    wii = dolphin;
    arcade = fbneo;
    fbneo = fbneo;
  }
  # Tender system folder -> standalone emulator command, called with the ROM path.
, standalone ? { }
  # Tender system folder -> saves its resolver cannot see; see standalone_saves.py.
  #   { emulator; dir; ext; serverExt ? null; }  one <rom stem><ext> file in dir
  #   { emulator; dir; stage; layout; }          a folder per game, synced as a zip
, standaloneSaves ? { }
}:

let

  # Same .so name nixpkgs' mkLibretroCore produces.
  coreSo = c: "${c}${c.libretroCore}/${lib.replaceStrings [ "-" ] [ "_" ] c.core}_libretro.so";

  missingCores = lib.filter (c: !(lib.elem c retroarch.cores)) (lib.unique (lib.attrValues coreFor));

  # Per-core save folder RetroArch uses (sort_savefiles_enable): the .info
  # corename, unless the core reports a different library_name at runtime.
  saveDirOverride = { dolphin = "dolphin-emu"; };

  nixCores = writeText "nix_cores.json" (builtins.toJSON (lib.mapAttrs
    (_: c: {
      so = coreSo c;
      info = "${libretro-core-info}/share/retroarch/cores/${lib.replaceStrings [ "-" ] [ "_" ] c.core}_libretro.info";
      corename = saveDirOverride.${c.core} or null;
    })
    coreFor));

  # Answers Tender's "which core runs this ROM" from the table above, since
  # its own resolver needs RetroDECK's es_systems.xml.
  nixCoresPy = writeText "nix_cores.py" (
    ''
      import json
      import os
      import re

      with open(os.path.join(os.path.dirname(__file__), "nix_cores.json")) as f:
          _TABLE = json.load(f)


      def _info_corename(entry):
          try:
              with open(entry["info"]) as f:
                  m = re.search(r'^corename\s*=\s*"([^"]*)"', f.read(), re.M)
              return m.group(1) if m else None
          except OSError:
              return None


      def _corename(entry):
          return entry.get("corename") or _info_corename(entry)


      def label_for_system(system):
          entry = _TABLE.get(system)
          return _info_corename(entry) if entry else None


      def core_for_rom(uow_factory, rom_id):
          with uow_factory() as uow:
              installed = uow.rom_installs.get(int(rom_id))
          entry = _TABLE.get(installed.system) if installed else None
          return (entry["so"], None) if entry else None


      def corename_for_so(core_so):
          for entry in _TABLE.values():
              if entry["so"] == core_so:
                  return _corename(entry)
          return None
    ''
  );

  launcher = writeShellScript "rom-launcher" ''
    # Tender's Steam shortcut launcher, redirected to Nix RetroArch.
    # Tender bakes `flatpak run net.retrodeck.retrodeck [-e "..."] '<rom>'`;
    # the core is chosen from the system folder the ROM lies in.
    set -euo pipefail

    ROMS="$HOME/Games/Roms"

    if [[ $# -eq 0 ]]; then
      echo "Usage: rom-launcher <command> [args...]" >&2
      exit 1
    fi

    if [[ " $* " != *" net.retrodeck.retrodeck "* ]]; then
      exec "$@"
    fi

    rom="''${!#}"
    rel="''${rom#"$ROMS"/}"
    if [[ $rel == "$rom" ]]; then
      echo "rom-launcher: $rom is not under $ROMS" >&2
      exit 1
    fi
    system="''${rel%%/*}"
    ${lib.optionalString (standalone != { }) ''

    case "$system" in
    ${lib.concatStrings (lib.mapAttrsToList (sys: cmd: ''
      ${lib.escapeShellArg sys}) exec ${cmd} "$rom" ;;
    '') standalone)}
    esac
    ''}
    case "$system" in
    ${lib.concatStrings (lib.mapAttrsToList (sys: c: ''
      ${lib.escapeShellArg sys}) core=${lib.escapeShellArg (coreSo c)} ;;
    '') coreFor)}
      *) echo "rom-launcher: no core mapped for system '$system'" >&2; exit 1 ;;
    esac

    exec ${retroarch}/bin/retroarch -L "$core" "$rom"
  '';

  # Tender only bundles the x86_64 build of its save-sync core.
  gavel = stdenv.mkDerivation {
    pname = "romm-gavel";
    version = "1.0.1";
    src = fetchFromGitHub {
      owner = "danielcopper";
      repo = "romm-gavel";
      rev = "v1.0.1";
      hash = "sha256-6eJmgB0gstwvpbEePhh/BPB8vDk0iB7RxE5vOd5zwko=";
    };
    buildPhase = ''
      $CC -std=c99 -Wall -Wextra -Werror -pedantic -fno-builtin -fPIC -shared -O2 core/gavel.c -o libgavel.so
    '';
    installPhase = ''
      install -Dm755 libgavel.so $out/lib/libgavel.so
    '';
  };

  tender = runCommand "romm-tender-0.33.0"
    {
      src = fetchurl {
        url = "https://github.com/danielcopper/romm-tender/releases/download/tender-v0.33.0/tender.zip";
        hash = "sha256-evnsYDrnE/lrsizwCW/LOuJB2Syb1SZrF/DXhNzpqb8=";
      };
      nativeBuildInputs = [ unzip ];
      passthru = { inherit launcher; };
    } ''
      # The zip ships a duplicate README.md; -o overwrites instead of prompting.
      mkdir unpacked
      unzip -o -q $src -d unpacked
      cp -r unpacked/romm-tender $out
      chmod -R u+w $out${lib.optionalString (!stdenv.hostPlatform.isx86_64) ''

      substituteInPlace $out/py_modules/adapters/gavel_native.py \
        --replace-fail 'os.path.join(os.path.dirname(__file__), os.pardir, "native", "libgavel-x86_64-linux.so")' \
                       '"${gavel}/lib/libgavel.so"'
    ''}

      # Fail the build if a mapped core isn't where the launcher expects it.
      ${lib.concatMapStrings (c: ''
        test -f ${coreSo c} || { echo "missing core: ${coreSo c}" >&2; exit 1; }
      '') (lib.unique (lib.attrValues coreFor))}

      install -m 755 ${launcher} $out/bin/rom-launcher

      # No RetroDECK: ROMs, BIOS and saves in the folders retroarch.cfg points at.
      substituteInPlace $out/py_modules/adapters/retrodeck_paths.py \
        --replace-fail 'return self._get_path("roms_path", "roms")' \
                       'return os.path.join(self._user_home, "Games", "Roms")' \
        --replace-fail 'return self._get_path("bios_path", "bios")' \
                       'return os.path.join(self._user_home, "Games", "Retroarch", "System")' \
        --replace-fail 'return self._get_path("saves_path", "saves")' \
                       'return os.path.join(self._user_home, "Games", "Retroarch", "Saves")'

      cp ${nixCores} $out/py_modules/nix_cores.json
      cp ${nixCoresPy} $out/py_modules/nix_cores.py
      substituteInPlace $out/py_modules/services/saves/rom_info.py \
        --replace-fail 'core_so, _label = self._active_core.active_core_for_rom(rom_id)' \
                       'core_so, _label = __import__("nix_cores").core_for_rom(self._uow_factory, rom_id) or self._active_core.active_core_for_rom(rom_id)' \
        --replace-fail 'corename = self._get_core_name(core_so)' \
                       'corename = __import__("nix_cores").corename_for_so(core_so) or self._get_core_name(core_so)' \
        --replace-fail 'emulator_label=emulator.label if emulator is not None else None,' \
                       'emulator_label=emulator.label if emulator is not None else __import__("nix_cores").label_for_system(system),'${lib.optionalString (standaloneSaves != { }) ''

      cp ${./standalone_saves.py} $out/py_modules/standalone_saves.py
      cp ${writeText "standalone_saves.json" (builtins.toJSON standaloneSaves)} $out/py_modules/standalone_saves.json
      substituteInPlace $out/py_modules/services/saves/rom_info.py \
        --replace-fail 'saves_dir = resolve_save_dir(' \
                       'saves_dir = __import__("standalone_saves").saves_dir(system, file_path) or resolve_save_dir(' \
        --replace-fail 'return self._save_locations.resolve_save_answer(' \
                       'return __import__("standalone_saves").save_answer(system, content_path, installed) or self._save_locations.resolve_save_answer('
      substituteInPlace $out/py_modules/services/saves/_helpers.py \
        --replace-fail 'return pick_download_name(known_names, result.filename)' \
                       'return pick_download_name(known_names, __import__("standalone_saves").server_to_local_name(known_names, result.filename))'
      substituteInPlace $out/py_modules/services/saves/sync_engine/matrix.py \
        --replace-fail 'emulator = build_emulator_tag(core_so)' \
                       'emulator = __import__("standalone_saves").emulator_tag(system) or build_emulator_tag(core_so)' \
        --replace-fail 'self._save_file_store.rename(tmp_path, local_path)' \
                       'self._save_file_store.rename(tmp_path, local_path); __import__("standalone_saves").after_download(local_path)'
      substituteInPlace $out/py_modules/adapters/romm/http.py \
        --replace-fail 'filename = os.path.basename(file_path)' \
                       'filename = __import__("standalone_saves").upload_name(file_path)'
    ''}
      substituteInPlace $out/py_modules/services/migration/save_sort.py \
        --replace-fail 'emulator_label=emulator.label if emulator is not None else None,' \
                       'emulator_label=emulator.label if emulator is not None else __import__("nix_cores").label_for_system(system),'
  '';
in
assert lib.assertMsg (missingCores == [ ])
  "romm-tender: cores not in retroarch: ${toString (map (c: c.name) missingCores)}";
tender
