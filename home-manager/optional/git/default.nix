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
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOpM3ETAqRsx/mFs//pHp7vMcRQnWklwLkrA7hh8b9jq";
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
