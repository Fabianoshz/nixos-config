{ buildFHSEnv, writeShellScript, SDL2, wget }:
buildFHSEnv {
  name = "pico8";
  targetPkgs = _: [
    SDL2
    wget
  ];
  runScript = writeShellScript "pico8" ''
    exec "$HOME/Games/pico-8/pico8_64" "$@"
  '';
}
