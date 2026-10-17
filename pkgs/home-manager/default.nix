{ applyPatches
, src
}:

applyPatches {
  name = "home-manager-patched";
  inherit src;
  patches = [ ./syncthing-stale-ids.patch ];
}
