{ lib, fetchFromGitHub, fetchpatch, libretro }:
libretro.mkLibretroCore {
  core = "fake08";
  version = "0-unstable-2026-06-13";

  src = fetchFromGitHub {
    owner = "jtothebell";
    repo = "fake-08";
    rev = "814991a2571ad3970e386cef48f3b148aa1c27b9";
    hash = "sha256-+2jhG4hMc5P1it1/ksTlWDRKAvRZUpkq2CZ2NxcEITg=";
    fetchSubmodules = true;
  };

  # https://github.com/jtothebell/fake-08/pull/288
  patches = map
    ({ rev, hash }: fetchpatch {
      url = "https://github.com/jtothebell/fake-08/commit/${rev}.patch";
      inherit hash;
    }) [
    { rev = "690cd3439b07db41350163cfa99fc47f0dabc204"; hash = "sha256-gO4CYLQ1tGkQAp39QXMjcHB/nSHissQ9CwMwqJGQdlo="; }
    { rev = "3e5cba5d6019f4ec20bd2145688ef95639f3a66a"; hash = "sha256-COJpkY/n/o353JlEDK1C7ZOkDyXEs8p59TFwT2boA24="; }
    { rev = "0c958a84f433fb2ced1377d1387d63952523bfb7"; hash = "sha256-T86qnd+gW5zV8H0Jtg1T9KnzEJ3rFsNJysHqIMgZ2Zg="; }
  ];

  makefile = "Makefile";
  preBuild = "cd platform/libretro";

  meta = {
    description = "PICO-8 emulator";
    homepage = "https://github.com/jtothebell/fake-08";
    license = lib.licenses.mit;
  };
}
