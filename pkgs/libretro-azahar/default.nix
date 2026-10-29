{ lib, stdenv, fetchFromGitHub, cmake, pkg-config, python3 }:
stdenv.mkDerivation {
  pname = "libretro-azahar";
  version = "0-unstable-2026-05-27";

  src = fetchFromGitHub {
    owner = "Fabianoshz";
    repo = "azahar";
    rev = "e215bcbbe03ceab03796db5597dc2a90bf2c1cfe";
    hash = "sha256-Gga2fFsju5J3Zg3OdLDKVxqxARFjoChG1SWeQAlqkAs=";
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
    homepage = "https://github.com/Fabianoshz/azahar";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
}
