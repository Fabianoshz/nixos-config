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
, python3
, wayland-scanner
, alsa-lib
, dbus
, libdecor
, libdrm
, libgbm
, libpulseaudio
, libusb1
, libx11
, libxcb
, libxcursor
, libxext
, libxfixes
, libxi
, libxkbcommon
, libxrandr
, libxrender
, libxscrnsaver
, libxtst
, pipewire
, systemdLibs
, vulkan-headers
, vulkan-loader
, wayland
, xorgproto
  # Add to Steam writes the CLI's own path, a store path that dies on rebuild.
, steamShortcutExe ? "/run/current-system/sw/bin/retcomm"
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
  # built out of nixpkgs instead. It also looks for Python under python/ before
  # downloading a generic-linux one, which NixOS can't run either.
  toolchain = symlinkJoin {
    name = "retcomm-toolchain";
    paths = [ cmake ninja clang pkg-config wayland-scanner ];
    postBuild = ''
      ln -s ${python3} $out/python
    '';
  };

  # PSX titles build SDL3 from source, which then dlopens these at runtime.
  sdlDeps = [
    alsa-lib
    dbus
    libdecor
    libdrm
    libgbm
    libGL
    libpulseaudio
    libusb1
    libx11
    libxcb
    libxcursor
    libxext
    libxfixes
    libxi
    libxkbcommon
    libxrandr
    libxrender
    libxscrnsaver
    libxtst
    pipewire
    systemdLibs
    vulkan-headers
    vulkan-loader
    wayland
    xorgproto
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "retro-launcher";
  version = "0.8.7";

  # third_party/Retro-Runtime is a submodule.
  src = fetchFromGitHub {
    owner = "RetroPortingToolKit";
    repo = "Retro-Launcher";
    rev = "v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-tdZjVwcLhQcoVaqHA5xVoE4gf+yIVr31kZOPtqRg8Hk=";
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

  postPatch = ''
    substituteInPlace src/steam/steam_shortcut.cpp \
      --replace-fail 'const fs::path cli = self.parent_path() / "retcomm";' \
                     'const fs::path cli = "${steamShortcutExe}";'
  '';

  cmakeFlags = [
    (lib.cmakeFeature "RETCOMM_IMGUI_DIR" "${imgui-src}")
    # CMakeLists still carries 0.1.1; the releases moved on without it, and this
    # string is what the about text and the self updater compare against.
    (lib.cmakeFeature "RETCOMM_VERSION" finalAttrs.version)
    # Normally from `git describe` on the submodule; without it the runner says
    # "dev" and the runtime updater treats every release as newer.
    (lib.cmakeFeature "RETRO_RUNTIME_VERSION" "0.2.5")
  ];

  postInstall = ''
    # Only the AppImage packaging installs this upstream; the icon it names is
    # already in share/icons/hicolor from CMake's own install rules.
    install -Dm644 $src/packaging/linux/retcomm.desktop \
      $out/share/applications/retcomm.desktop

    # retcomm-hub is upstream's compatibility symlink to retro-hub.
    for exe in retcomm retro-hub; do
      wrapProgram $out/bin/$exe \
        --set RETCOMM_TOOLCHAIN_DIR "${toolchain}" \
        --prefix PKG_CONFIG_PATH : "${lib.makeSearchPathOutput "dev" "lib/pkgconfig" sdlDeps}:${lib.makeSearchPathOutput "dev" "share/pkgconfig" sdlDeps}" \
        --prefix CMAKE_PREFIX_PATH : "${lib.concatMapStringsSep ":" (p: "${lib.getDev p}:${lib.getLib p}") sdlDeps}" \
        --prefix CPATH : "${lib.makeSearchPathOutput "dev" "include" sdlDeps}" \
        --prefix LIBRARY_PATH : "${lib.makeLibraryPath sdlDeps}" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath sdlDeps}"
    done
  '';

  meta = {
    description = "Hub for cataloguing, building and launching static recompilations";
    homepage = "https://github.com/RetroPortingToolKit/Retro-Launcher";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "retro-hub";
  };
})
