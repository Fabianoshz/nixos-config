{
  stdenv,
  lib,
  pkgs,
}:

stdenv.mkDerivation rec {
  name = "waydroid-exec";
  version = "1.0.0";
  phases = "installPhase";

  installPhase = ''
    mkdir -p $out/bin

    cp ${./waydroid-exec.sh} $out/bin/waydroid-exec
    chmod 0755 "$out/bin/waydroid-exec"
  '';

  meta = with lib; {
    description = "Exec script to facilitate the use of Waydroid";
    platforms = with platforms; linux;
    license = licenses.mit;
  };
}
