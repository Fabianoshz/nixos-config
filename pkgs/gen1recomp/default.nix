{ lib, stdenv, fetchurl, love, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "gen1recomp";
  version = "0.4.4";

  src = fetchurl {
    url = "https://github.com/bryanthaboi/gen1recomp/releases/download/v${version}/gen1recomp-${version}.love";
    hash = "sha256-DzqVxu8LNUreDuGJH6a1FxhW+QEWjnZarhPrYwb/338=";
  };

  nativeBuildInputs = [ makeWrapper ];
  dontUnpack = true;

  installPhase = ''
    install -Dm644 $src $out/share/gen1recomp/gen1recomp.love
    makeWrapper ${love}/bin/love $out/bin/gen1recomp \
      --add-flags $out/share/gen1recomp/gen1recomp.love
  '';

  meta = {
    description = "Native LÖVE2D recreation of classic Pokemon games";
    homepage = "https://github.com/bryanthaboi/gen1recomp";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "gen1recomp";
  };
}
