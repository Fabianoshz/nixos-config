{ lib
, stdenv
, llvmPackages_20
, fetchFromGitHub
, fetchurl
, cmake
, ninja
, pkg-config
, python3
, bash
, which
, gcc
, dbus
, openssl
, curl
, libdrm
, libGL
, vulkan-headers
, vulkan-loader
, alsa-lib
, libpulseaudio
, wayland
, libX11
, libxcb
, libxkbcommon
, zlib
}:

let
  ffmpegPrebuilt = {
    aarch64-linux = fetchurl {
      url = "https://github.com/Vita3K/ffmpeg-core/releases/download/e744193/ffmpeg-linux-arm64.zip";
      hash = "sha256-I8FXlKewQeaLl2/zMbb1wTK0l/XHdSd3RpCKRYElgm8=";
    };
    x86_64-linux = fetchurl {
      url = "https://github.com/Vita3K/ffmpeg-core/releases/download/e744193/ffmpeg-linux-x64.zip";
      hash = "sha256-C0fMUAg6YD9U7ISVjAGS7zF1TmVF4XpGjOdFE2H1i7E=";
    };
  }.${stdenv.hostPlatform.system};
in
llvmPackages_20.stdenv.mkDerivation {
  pname = "libretro-vita3k";
  version = "0.2.1-4123-unstable-2026-10-24";

  src = fetchFromGitHub {
    owner = "WizzardSK";
    repo = "vita3k-libretro";
    rev = "ab4891a3f53a22264f88233a3238f0e887104cb3";
    hash = "sha256-OojmUXDpp4MfyrWAcbZt5bNWhhYpemNWnkaZ/Ay7Tek=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    python3
    bash
    which
    gcc
    llvmPackages_20.lld
  ];

  buildInputs = [
    dbus
    openssl
    curl
    libdrm
    libGL
    vulkan-headers
    vulkan-loader
    alsa-lib
    libpulseaudio
    wayland
    libX11
    libxcb
    libxkbcommon
    zlib
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_LIBRETRO" true)
    (lib.cmakeFeature "USE_LTO" "NEVER")
    (lib.cmakeBool "VITA3K_FORCE_CUSTOM_BOOST" true)
    (lib.cmakeBool "USE_DISCORD_RICH_PRESENCE" false)
    (lib.cmakeBool "FMT_MODULE" false)
    (lib.cmakeBool "CMAKE_CXX_SCAN_FOR_MODULES" false)
    (lib.cmakeBool "CMAKE_POSITION_INDEPENDENT_CODE" true)
    (lib.cmakeFeature "CMAKE_LINKER_TYPE" "LLD")
    (lib.cmakeFeature "CMAKE_SHARED_LINKER_FLAGS" "-Wl,-Bsymbolic")
  ];

  preConfigure = ''
    substituteInPlace external/boost/tools/build/src/engine/build.sh \
      --replace-fail "/usr/bin/env sh" "${bash}/bin/sh"
    patchShebangs external/boost
    install -Dm644 ${ffmpegPrebuilt} build/external/ffmpeg.zip
  '';

  buildFlags = [ "vita3k_libretro" ];

  installPhase = ''
    runHook preInstall
    install -Dm755 lib/vita3k_libretro.so \
      $out/lib/retroarch/cores/vita3k_libretro.so
    install -Dm644 ../vita3k_libretro.info \
      $out/lib/retroarch/cores/vita3k_libretro.info
    runHook postInstall
  '';

  passthru = {
    core = "vita3k";
    libretroCore = "/lib/retroarch/cores";
  };

  meta = {
    description = "PlayStation Vita emulator libretro core";
    homepage = "https://github.com/WizzardSK/vita3k-libretro";
    license = lib.licenses.gpl2Only;
    platforms = [ "aarch64-linux" "x86_64-linux" ];
  };
}
