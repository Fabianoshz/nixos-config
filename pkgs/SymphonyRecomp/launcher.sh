#!/usr/bin/env bash
# SymphonyRecomp reads its disc images and writes its settings, memory cards and
# mods next to the executable, so it cannot run from the Nix store. Mirror the
# store payload into a writable directory and launch the game from there.
#
# Put the game files in $gamedir/disc, named exactly as upstream expects:
#   Castlevania - Symphony of the Night (Track 1).bin
#   Castlevania - Symphony of the Night (Track 2).bin
#   Castlevania - Symphony of the Night (USA).cue
set -euo pipefail

export PATH="@path@:$PATH"

payload="@payload@"
gamedir="${SYMPHONY_RECOMP_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/symphony-recomp}"

mkdir -p "$gamedir/disc"

# Drop links left behind by a previous version of the payload.
find "$gamedir" -maxdepth 1 -type l -delete

# The apphost looks for sotn.dll next to its own resolved path, so it has to be
# a real file in the game directory. Everything else can point at the store.
# rm first: overwriting in place would fail with ETXTBSY if a copy is running.
rm -f "$gamedir/sotn"
install -m755 "$payload/sotn" "$gamedir/sotn"
for entry in "$payload"/*; do
  name="$(basename "$entry")"
  case "$name" in
  sotn | mods) continue ;;
  esac
  # -f also reverts any file the in-game updater wrote over a link.
  ln -sfn "$entry" "$gamedir/$name"
done

# Refresh the bundled first party mods, leaving anything else the user dropped
# into mods/ alone.
mkdir -p "$gamedir/mods"
for mod in "$payload"/mods/*; do
  name="$(basename "$mod")"
  rm -rf "$gamedir/mods/$name"
  cp -r "$mod" "$gamedir/mods/$name"
  chmod -R u+w "$gamedir/mods/$name"
done

export DOTNET_ROOT="@dotnetRoot@"
export LD_LIBRARY_PATH="@libraryPath@${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

cd "$gamedir"
exec ./sotn "$@"
