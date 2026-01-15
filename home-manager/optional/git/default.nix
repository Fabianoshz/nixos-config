{ lib, pkgs, ... }:
with lib;
let
  general = builtins.fromJSON (builtins.readFile ../../../sensitive/general.json);
in
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Fabiano Honorato";
        email = general.emails.personal;
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
