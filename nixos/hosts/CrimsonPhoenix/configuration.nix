# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, pkgs, ... }:
with lib;
let
  general = builtins.fromJSON (builtins.readFile ../../../sensitive/general.json);
in
{
  nix.settings = {
    # Enable flakes and new 'nix' command
    experimental-features = "nix-command flakes";
  };

  nix.optimise.automatic = true;

  # Configure networking
  networking.hostName = "CrimsonPhoenix";

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.fabiano = {
    openssh.authorizedKeys.keys = [
      general.ssh.general
    ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  environment.shells = with pkgs; [ zsh ];

  nixpkgs.config.allowUnfree = true;

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };

  ids.gids.nixbld = 30000;

  system.stateVersion = 5;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
