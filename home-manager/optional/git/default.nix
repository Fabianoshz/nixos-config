{ lib, pkgs, ... }:
with lib;
let
  general = builtins.fromJSON (builtins.readFile ../../../sensitive/general.json);
in
{
  programs.git = {
    enable = true;
    userName = "Fabiano Honorato";
    userEmail = general.emails.personal;
    extraConfig = {
      user = {
        signingKey = general.ssh.github;
      };
      gpg = {
        format = "ssh";
      };
      commit = {
        gpgSign = true;
      };
      push = {
        autoSetupRemote = true;
      };
    };
  };
}
