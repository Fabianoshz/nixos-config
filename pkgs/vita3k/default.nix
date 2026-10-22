{ lib
, stdenv
, fetchurl
, p7zip
, autoPatchelfHook
, makeWrapper
, qt6
, xorg
, wayland
, libGL
, libglvnd
, libxkbcommon
, brotli
, zstd
, openssl
, zlib
, vulkan-loader
, alsa-lib
, pipewire
, libjack2
, sndio
, libdecor
, fribidi
, liburing
}:

stdenv.mkDerivation rec {
  pname = "vita3k";
  # Builds from 4115 on need GLIBC_2.43; nixpkgs 26.05 has 2.42.
  version = "4105";

  src = fetchurl {
    url = "https://github.com/Vita3K/Vita3K-builds/releases/download/${version}/vita3k-${version}-4b405e8b-ubuntu-aarch64.7z";
    hash = "sha256-6Py/40ITXU5voFp6z68JESwgvXM3F9ac20TVULk+l/U=";
  };

  nativeBuildInputs = [ p7zip autoPatchelfHook makeWrapper qt6.wrapQtAppsHook ];

  buildInputs = [
    qt6.qtbase
    qt6.qtsvg
    qt6.qtmultimedia
    xorg.libX11
    xorg.libXext
    xorg.libSM
    xorg.libICE
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXScrnSaver
    alsa-lib
    pipewire
    libjack2
    sndio
    libdecor
    fribidi
    liburing
    wayland
    libGL
    libglvnd
    libxkbcommon
    brotli
    zstd
    openssl
    zlib
  ];

  runtimeDependencies = [ vulkan-loader ];

  # GLES 1 isn't shipped by any modern GL stack; Steam provides libsteam_api.
  autoPatchelfIgnoreMissingDeps = [ "libGLES_CM.so.1" "libsteam_api.so" ];

  unpackPhase = ''
    7z x $src -o"$PWD/vita3k" >/dev/null
  '';

  installPhase = ''
    mkdir -p $out/lib/vita3k $out/bin
    cp -r vita3k/. $out/lib/vita3k/
    chmod +x $out/lib/vita3k/Vita3K
    makeWrapper $out/lib/vita3k/Vita3K $out/bin/Vita3K
  '';

  meta.platforms = [ "aarch64-linux" ];
}
