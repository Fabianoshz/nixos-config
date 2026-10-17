{ lib, ... }:
let
  taps = [ ];

  brews = [ ];

  casks = [
    "discord"
    "grayjay"
    "iterm2"
    "logseq"
    "obsidian"
    "onlyoffice"
    "steam"
    "utm"
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
