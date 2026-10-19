# SDL3 at the commit Steam bundles, with battery reporting for the Vader 4 Pro.
{ lib
, sdl3
, fetchFromGitHub
}:

let
  # ubuntu12_32/libSDL3.so.0 shipped with Steam client 1791918634.
  valve = {
    size = 3911164;
    sha256 = "770801484962a75780b8eebed5e16b4f4735c1dbf422445af48764cff415ea97";
  };
in
sdl3.overrideAttrs (old: {
  version = "3.4.0-unstable-2026-10-13";

  src = fetchFromGitHub {
    owner = "libsdl-org";
    repo = "SDL";
    rev = "ab5541ec5d4377dcc20a701897437f07ba71566f";
    hash = "sha256-G8u68c03zA7y3bu7CeTXlWg6u3xkj5krTLIFwOczBXk=";
  };

  patches = (old.patches or [ ]) ++ [ ./flydigi-v1-battery.patch ];

  # Steam's runtime libraries win over our RUNPATH, so dlopen like Valve's build.
  cmakeFlags = map
    (f: if f == lib.cmakeBool "SDL_DEPS_SHARED" false then lib.cmakeBool "SDL_DEPS_SHARED" true else f)
    old.cmakeFlags;

  cmakeBuildType = "MinSizeRel";

  doCheck = false;

  # Steam verifies its files by size only.
  postFixup = (old.postFixup or "") + ''
    so=$(readlink -f $lib/lib/libSDL3.so.0)
    if [ $(stat -c %s $so) -gt ${toString valve.size} ]; then
      echo "libSDL3 is larger than Steam's ${toString valve.size} bytes" >&2
      exit 1
    fi
    truncate -s ${toString valve.size} $so
  '';

  passthru = (old.passthru or { }) // { inherit valve; };
})
