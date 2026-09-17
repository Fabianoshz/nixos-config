{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, copyDesktopItems
, makeDesktopItem
, wrapGAppsHook3
, coreutils
, findutils
, dotnet-runtime_10
, alsa-lib
, glib
, gsettings-desktop-schemas
, gtk3
, libGL
, libpulseaudio
, libX11
, libXcursor
, libXext
, libXfixes
, libXi
, libXinerama
, libXrandr
, libXrender
, libxkbcommon
, libxxf86vm
, vulkan-loader
, wayland
}:

let
  # dlopen'd by the bundled SDL2/GLFW/OpenAL, so autoPatchelf can't see them and
  # they have to be on LD_LIBRARY_PATH instead.
  runtimeLibs = [
    alsa-lib
    libGL
    libpulseaudio
    libX11
    libXcursor
    libXext
    libXfixes
    libXi
    libXinerama
    libXrandr
    libXrender
    libxkbcommon
    libxxf86vm
    vulkan-loader
    wayland
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "symphony-recomp";
  version = "0.5.1b";

  src = fetchurl {
    url = "https://github.com/BlackLabelHQ/SymphonyRecomp/releases/download/v${finalAttrs.version}/SymphonyRecomp-v${finalAttrs.version}-linux-x64.tar.gz";
    hash = "sha256-Ncq+6ON4rQwTYV7IvbtPudZR+SpCo6TAQ129/mS+VtU=";
  };

  # The tarball has no top level directory.
  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gsettings-desktop-schemas
    gtk3
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/symphony-recomp
    cp -r . $out/share/symphony-recomp/

    # Upstream's launcher downloads a .NET runtime into $HOME; ours uses the one
    # from nixpkgs.
    rm $out/share/symphony-recomp/run.sh

    install -d $out/bin
    substitute ${./launcher.sh} $out/bin/symphony-recomp \
      --subst-var-by payload "$out/share/symphony-recomp" \
      --subst-var-by dotnetRoot "${dotnet-runtime_10}/share/dotnet" \
      --subst-var-by path "${lib.makeBinPath [ coreutils findutils ]}" \
      --subst-var-by libraryPath "${lib.makeLibraryPath runtimeLibs}"
    chmod +x $out/bin/symphony-recomp

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "symphony-recomp";
      exec = "symphony-recomp";
      desktopName = "SymphonyRecomp";
      comment = "Castlevania: Symphony of the Night static recompilation";
      categories = [ "Game" ];
    })
  ];

  meta = {
    description = "Static recompilation of Castlevania: Symphony of the Night (PSX)";
    homepage = "https://github.com/BlackLabelHQ/SymphonyRecomp";
    # The upstream repository ships no license, and the release contains
    # recompiled game code. Needs game files the user owns to be playable.
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "symphony-recomp";
  };
})
