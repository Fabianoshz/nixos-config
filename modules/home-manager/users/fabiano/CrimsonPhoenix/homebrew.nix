{ lib, ... }:
let
  taps = [
    "homebrew/services"
  ];

  brews = [
    "syncthing"
  ];

  casks = [
    "8bitdo-ultimate-software"
    "battle-net"
    "firefox"
    "league-of-legends"
    "onlyoffice"
    "steam"
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
      /opt/homebrew/bin/brew bundle install --cleanup --no-upgrade --force --no-lock --global
    '';
  };
}