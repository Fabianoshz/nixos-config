{ lib, stdenv, fetchFromGitHub, cmake, git, pkg-config, python3, libGL, libX11 }:
let
  deps = {
    MELONDS = fetchFromGitHub {
      owner = "JesseTG";
      repo = "melonDS";
      rev = "16f127dbb587a73371827ce79689c5d237c4b59b";
      hash = "sha256-55LrwWBPljMMoTOKsmZIBiVICFNm9Gr/GJlCvdKWUkA=";
    };
    LIBRETRO-COMMON = fetchFromGitHub {
      owner = "libretro";
      repo = "libretro-common";
      rev = "fa8a1b572a444fcb552007019f8caf68281108aa";
      hash = "sha256-kI0hHiEr64wKvMF4di3rUMwoM2dEjEzpSPHFNILj6oE=";
    };
    EMBED-BINARIES = fetchFromGitHub {
      owner = "andoalon";
      repo = "embed-binaries";
      rev = "078b62beba97e8192c99bfb16d5e17220cfc7598";
      hash = "sha256-EkK+ZCbrZ2Y9wJ864OIwRWDfHcmxzKMco0QAkLOQOwY=";
    };
    GLM = fetchFromGitHub {
      owner = "g-truc";
      repo = "glm";
      rev = "6f14f4792a0cde5d0cf2c910506724d61cb95834";
      hash = "sha256-vjksqNeSPlPIPw0G4M/ik5w5uMwDNuBNJenjBL1vSJE=";
    };
    LIBSLIRP = fetchFromGitHub {
      owner = "JesseTG";
      repo = "libslirp-mirror";
      rev = "e61dbd459c8c06607b3a84694489427e8ec60f17";
      hash = "sha256-WQIJjnNJHF63gNfznnrGt4jAzrhHfslOATsjcbfbAg4=";
    };
    PNTR = fetchFromGitHub {
      owner = "robloach";
      repo = "pntr";
      rev = "a47fe167703b0ac3bfad00785b20b0dce6712509";
      hash = "sha256-DWYL0TI1UetbUD0qr/f0VZSu1JJvrBzqqT+m6ZfWraw=";
    };
    FMT = fetchFromGitHub {
      owner = "fmtlib";
      repo = "fmt";
      rev = "1be298e1bd68957e4cd352e1f676f00e07dcfb57";
      hash = "sha256-Tc7PmNxUv7ajw6GaHPGEEtrD/fl6is7RB8TPestJa1o=";
    };
    YAMC = fetchFromGitHub {
      owner = "yohhoy";
      repo = "yamc";
      rev = "4e015a7e8eb0d61c34e6928676c8c78881a72d73";
      hash = "sha256-J5wAqF5yQ5KYArJJyKzaqscWsXq+KAPKXybYfVgasXs=";
    };
    SPAN-LITE = fetchFromGitHub {
      owner = "martinmoene";
      repo = "span-lite";
      rev = "f63fe2974943b5f555b928b10d910e457fbb93d4";
      hash = "sha256-N/QnXIkw+XtLDj1y1r2ahHLUsq0zI2EJw2G0qEamt7Y=";
    };
    DATE = fetchFromGitHub {
      owner = "HowardHinnant";
      repo = "date";
      rev = "179a6b921ccd6179b5b04dce812a89f71a51b4df";
      hash = "sha256-GTWSnBvLM6W7Z2+dvl2aa31fFsrBp5/qlsuKT26IaKo=";
    };
    ZLIB = fetchFromGitHub {
      owner = "madler";
      repo = "zlib";
      rev = "da607da739fa6047df13e66a2af6b8bec7c2a498";
      hash = "sha256-Sthd9RsydSLaITNlBp6g1X35WKZdS4h7gr0QhRqdGoI=";
    };
  };
in
stdenv.mkDerivation {
  pname = "libretro-melonds-ds";
  version = "0-unstable-2026-10-23";

  src = fetchFromGitHub {
    owner = "Davey-Hughes";
    repo = "melonds-ds";
    rev = "052138f25f5dc615396b9594b2ec6498972cd5e5";
    hash = "sha256-SW2/utaGftpjeHM0rQKWqt+nvEZfYYe5vhGBs0ksSfc=";
  };

  nativeBuildInputs = [ cmake git pkg-config python3 ];
  buildInputs = [ libGL libX11 ];

  # CMAKE_MODULE_PATH points into ${FETCHCONTENT_BASE_DIR}/<name>-src, so
  # the sources sit there, not just anywhere FETCHCONTENT_SOURCE_DIR_* says.
  postUnpack = ''
    mkdir -p /build/fcdeps
  '' + lib.concatStrings (lib.mapAttrsToList
    (name: src: ''
      cp -r --no-preserve=mode ${src} /build/fcdeps/${lib.toLower name}-src
    '')
    deps);

  cmakeFlags = lib.mapAttrsToList
    (name: _:
      "-DFETCHCONTENT_SOURCE_DIR_${lib.replaceStrings [ "-" ] [ "_" ] name}=/build/fcdeps/${lib.toLower name}-src"
    )
    deps ++ [
    "-DFETCHCONTENT_BASE_DIR=/build/fcdeps"
    (lib.cmakeBool "FETCHCONTENT_FULLY_DISCONNECTED" true)
    (lib.cmakeBool "BUILD_TESTING" false)
  ];

  installPhase = ''
    runHook preInstall
    install -Dt $out/lib/retroarch/cores $(find . -name melondsds_libretro.so | head -1)
    runHook postInstall
  '';

  passthru = {
    core = "melondsds";
    libretroCore = "/lib/retroarch/cores";
  };

  meta = {
    description = "Nintendo DS emulator core (melonDS DS), with the video views PR";
    homepage = "https://github.com/JesseTG/melonds-ds/pull/335";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
  };
}
