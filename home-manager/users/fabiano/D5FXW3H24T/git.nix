{ lib, pkgs, ... }:
with lib;
let
  general = builtins.fromJSON (builtins.readFile ../../../../sensitive/general.json);
in
{
  programs.git = {
    enable = true;
    userName = "Fabiano Honorato";
    userEmail = general.emails.work;
    extraConfig = {
      user = {
        signingKey = general.ssh.work;
      };
      push = {
        autoSetupRemote = true;
      };
      gpg = {
        format = "ssh";
        "ssh" = {
          program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
        };
      };
      core = {
        fsmonitor = true;
        untrackedCache = true;
      };
      url = {
        "git@github.com:" = {
          insteadOf = "https://github.com/";
        };
      };
      commit = {
        gpgSign = true;
      };
      filter = {
        "lfs" = {
          process = "git-lfs filter-process";
          required = true;
          clean = "git-lfs clean -- %f";
          smudge = "git-lfs smudge -- %f";
        };
      };
    };
  };
}
