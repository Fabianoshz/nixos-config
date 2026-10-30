{ lib, stdenv, fetchFromGitHub, cmake, pkg-config, python3 }:
stdenv.mkDerivation {
  pname = "libretro-azahar";
  version = "0-unstable-2026-10-28";

  src = fetchFromGitHub {
    owner = "Davey-Hughes";
    repo = "azahar";
    rev = "231e7f8bc38faf715f44cc7af009ad5a535fa05a";
    hash = "sha256-qItdOdqw3cb4Eu8wcTD4a99mlMbjv4avTWELtpERBIk=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake pkg-config python3 ];

  cmakeFlags = [
    (lib.cmakeBool "ENABLE_LIBRETRO" true)
    (lib.cmakeBool "ENABLE_LTO" false)
  ];

  buildFlags = [ "azahar_libretro" ];

  installPhase = ''
    runHook preInstall
    install -Dt $out/lib/retroarch/cores bin/Release/azahar_libretro.so
    runHook postInstall
  '';

  passthru = {
    core = "azahar";
    libretroCore = "/lib/retroarch/cores";
  };

  meta = {
    description = "Nintendo 3DS emulator";
    homepage = "https://github.com/azahar-emu/azahar/pull/2718";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
}
