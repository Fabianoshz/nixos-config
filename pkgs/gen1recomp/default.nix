{ lib, stdenv, fetchurl, love, makeWrapper, copyDesktopItems, makeDesktopItem, unzip, imagemagick }:

stdenv.mkDerivation rec {
  pname = "gen1recomp";
  version = "0.4.4";

  src = fetchurl {
    url = "https://github.com/bryanthaboi/gen1recomp/releases/download/v${version}/gen1recomp-${version}.love";
    hash = "sha256-DzqVxu8LNUreDuGJH6a1FxhW+QEWjnZarhPrYwb/338=";
  };

  nativeBuildInputs = [ makeWrapper copyDesktopItems unzip imagemagick ];
  dontUnpack = true;

  desktopItems = [
    (makeDesktopItem {
      name = "gen1recomp";
      desktopName = "Gen1Recomp";
      comment = meta.description;
      exec = "gen1recomp";
      icon = "gen1recomp";
      categories = [ "Game" ];
    })
  ];

  installPhase = ''
    runHook preInstall
    install -Dm644 $src $out/share/gen1recomp/gen1recomp.love
    makeWrapper ${love}/bin/love $out/bin/gen1recomp \
      --add-flags $out/share/gen1recomp/gen1recomp.love

    unzip -p $src assets/logo/logo.png > logo.png
    mkdir -p $out/share/icons/hicolor/512x512/apps
    magick logo.png -resize 512x512 -background none -gravity center -extent 512x512 \
      $out/share/icons/hicolor/512x512/apps/gen1recomp.png
    runHook postInstall
  '';

  meta = {
    description = "Native LÖVE2D recreation of classic Pokemon games";
    homepage = "https://github.com/bryanthaboi/gen1recomp";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "gen1recomp";
  };
}
