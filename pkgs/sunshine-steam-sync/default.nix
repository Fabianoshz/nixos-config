{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenv.mkDerivation {
  pname = "sunshine-steam-sync";
  version = "0.1.0";

  src = ./.;

  nativeBuildInputs = [ pkgs.go ];

  buildPhase = ''
    export HOME=$TMPDIR
    export GOCACHE=$TMPDIR/go-cache
    export GOPATH=$TMPDIR/go

    # Build each binary separately
    go build -o sunshine-steam-sync game-sync.go
    go build -o sunshine-game-launcher game-launcher.go
    go build -o sunshine-game-client game-client.go
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp sunshine-steam-sync $out/bin/
    cp sunshine-game-launcher $out/bin/
    cp sunshine-game-client $out/bin/
  '';

  meta = with pkgs.lib; {
    description = "Sync Steam games to Sunshine streaming configuration and game launcher daemon";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
