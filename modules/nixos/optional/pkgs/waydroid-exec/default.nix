{
  stdenv,
  lib,
  pkgs,
  writeScript
}:

stdenv.mkDerivation rec {
  name = "waydroid-exec";
  version = "1.0.0";
  phases = "installPhase";

  buildInputs = [
    pkgs.cage
    pkgs.wlr-randr
  ];

  installPhase = ''
    mkdir -p $out/bin

    cp ${./waydroid-exec.sh} $out/bin/waydroid-exec
    chmod 0755 "$out/bin/waydroid-exec"
    cp ${./fix-controller.sh} $out/bin/fix-controller
    chmod 0755 "$out/bin/fix-controller"
  '';

  meta = with lib; {
    description = "Exec scripts to facilitate the use of Waydroid";
    platforms = with platforms; linux;
    license = licenses.mit;
  };
}
