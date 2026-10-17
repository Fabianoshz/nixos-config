{ pkgs }:
pkgs.retroarch.withCores (cores: with cores; [
  beetle-psx-hw
  beetle-saturn
  dolphin
  fbneo
  genesis-plus-gx
  mupen64plus
  pcsx2
  snes9x
])
