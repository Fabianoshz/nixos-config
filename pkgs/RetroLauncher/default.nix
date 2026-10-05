{ lib
, stdenv
, fetchFromGitHub
, cmake
, ninja
, pkg-config
, makeWrapper
, curl
, freetype
, libGL
, sdl3
, clang
, symlinkJoin
}:

let
  # Pinned by CMakeLists.txt, which otherwise FetchContents it at configure
  # time. The docking branch is not optional: the hub links
  # backends/imgui_impl_sdl3.cpp, which only ships there.
  imgui-src = fetchFromGitHub {
    owner = "ocornut";
    repo = "imgui";
    rev = "v1.91.9-docking";
    hash = "sha256-4L37NRR+dlkhdxuDjhLR45kgjyZK2uelKBlGZ1nQzgY=";
  };

  # Upstream downloads a prebuilt "cmake-clang-v1" pack to build the titles it
  # installs, which will not run on NixOS. It only asks that the directory it
  # is pointed at have bin/cmake, and puts that bin/ on PATH, so hand it one
  # built out of nixpkgs instead.
  toolchain = symlinkJoin {
    name = "retcomm-toolchain";
    paths = [ cmake ninja clang ];
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "retro-launcher";
  version = "0.6.42";

  src = fetchFromGitHub {
    owner = "RetroPortingToolKit";
    repo = "Retro-Launcher";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ubysNBxVNVYELw01oLgxBPigkqjqeYsQ/HZw/Uw5MO8=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    curl
    freetype
    libGL
    sdl3
  ];

  cmakeFlags = [
    (lib.cmakeFeature "RETCOMM_IMGUI_DIR" "${imgui-src}")
    # CMakeLists still carries 0.1.1; the releases moved on without it, and this
    # string is what the about text and the self updater compare against.
    (lib.cmakeFeature "RETCOMM_VERSION" finalAttrs.version)
  ];

  postInstall = ''
    # Only the AppImage packaging installs this upstream; the icon it names is
    # already in share/icons/hicolor from CMake's own install rules.
    install -Dm644 $src/packaging/linux/retcomm.desktop \
      $out/share/applications/retcomm.desktop

    for exe in retcomm retcomm-hub; do
      wrapProgram $out/bin/$exe \
        --set-default RETCOMM_TOOLCHAIN_DIR "${toolchain}"
    done
  '';

  meta = {
    description = "Hub for cataloguing, building and launching static recompilations";
    homepage = "https://github.com/RetroPortingToolKit/Retro-Launcher";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "retcomm-hub";
  };
})
