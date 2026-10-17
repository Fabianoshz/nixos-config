{ lib, ... }:
let
  taps = [
    "int128/kubelogin"
  ];

  brews = [
    "bazelisk"
    "colima"
    "gsed"
    "int128/kubelogin/kubelogin"
    "kubelogin"
    "oniguruma" # Something in bazel needs this
    "python3"
    "ripgrep"
    "snowflake-cli"
    "xz"
    "yq"
  ];

  casks = [
    "1password"
    "1password-cli"
    "claude"
    "cursor"
    "granola"
    "iterm2"
    # macOS .app bundles in the nix store get immutable flags that block nix-daemon GC (NixOS/nix#6765)
    "google-chrome"
  ];
in
with lib;
{
  home.sessionPath = [ "/opt/homebrew/bin" ];

  home.file.".Brewfile" = {
    text =
      (concatMapStrings
        (
          tap:
          ''tap "''
          + tap
          + ''
            "
          ''

        )
        taps)
      + (concatMapStrings
        (
          brew:
          ''brew "''
          + brew
          + ''
            "
          ''

        )
        brews)
      + (concatMapStrings
        (
          cask:
          ''cask "''
          + cask
          + ''
            "
          ''

        )
        casks);
    onChange = ''
      /opt/homebrew/bin/brew bundle install  --force --global
    '';
  };
}
