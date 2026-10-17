# Tender (romm-tender) 0.33.0, patched to run without RetroDECK:
# games launch in Nix RetroArch, ROMs live in ~/Games/Roms/<system>.
{ lib
, runCommand
, fetchurl
, unzip
, writeShellScript
, writeText
, libretro
, libretro-core-info
, retroarch
}:

let
  # Tender system folder -> libretro core. Every core must be in `retroarch.cores`.
  coreFor = with libretro; {
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
  };

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
  nixCoresPy = writeText "nix_cores.py" ''
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
  '';

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

    case "$system" in
    ${lib.concatStrings (lib.mapAttrsToList (sys: c: ''
      ${lib.escapeShellArg sys}) core=${lib.escapeShellArg (coreSo c)} ;;
    '') coreFor)}
      *) echo "rom-launcher: no core mapped for system '$system'" >&2; exit 1 ;;
    esac

    exec ${retroarch}/bin/retroarch -L "$core" "$rom"
  '';

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
    chmod -R u+w $out

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
                     'emulator_label=emulator.label if emulator is not None else __import__("nix_cores").label_for_system(system),'
    substituteInPlace $out/py_modules/services/migration/save_sort.py \
      --replace-fail 'emulator_label=emulator.label if emulator is not None else None,' \
                     'emulator_label=emulator.label if emulator is not None else __import__("nix_cores").label_for_system(system),'
  '';
in
assert lib.assertMsg (missingCores == [ ])
  "romm-tender: cores not in retroarch: ${toString (map (c: c.name) missingCores)}";
tender
