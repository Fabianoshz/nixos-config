{ lib, ... }:
let
  taps = [
    "int128/kubelogin"
  ];

  brews = [
    "bazelisk"
    "gsed"
    "int128/kubelogin/kubelogin"
    "kubelogin"
    "oniguruma" # Something in bazel needs this
    "python@3.13"
    "xz"
    "yq"
  ];

  casks = [
    "1password"
    "1password-cli"
    "container"
    "cursor"
    "utm"
  ];
in
with lib;
{
  home.sessionPath = [ "/opt/homebrew/bin" ];

  home.file.".Brewfile" = {
    text =
      (concatMapStrings (
        tap:
        ''tap "''
        + tap
        + ''
          "
        ''

      ) taps)
      + (concatMapStrings (
        brew:
        ''brew "''
        + brew
        + ''
          "
        ''

      ) brews)
      + (concatMapStrings (
        cask:
        ''cask "''
        + cask
        + ''
          "
        ''

      ) casks);
    onChange = ''
      /opt/homebrew/bin/brew bundle install --cleanup --no-upgrade --force --global
    '';
  };
}
