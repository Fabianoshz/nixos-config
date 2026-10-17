# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ~@~Xnixos-help~@~Y).

{ pkgs, lib, ... }:
{
  nix.settings = {
    # Enable flakes and new 'nix' command
    experimental-features = "nix-command flakes";
    download-buffer-size = 134217728; # 128 MB
  };

  nix.optimise.automatic = true;

  # Configure networking
  networking.hostName = "D5FXW3H24T";

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Define a user account. Don't forget to set a password with ~@~Xpasswd~@~Y.
  users.users.fabiano = {
    shell = pkgs.zsh;
  };

  fonts.packages = [
    pkgs.meslo-lgs-nf
  ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

  programs.zsh.enable = true;

  environment.shells = with pkgs; [ zsh ];

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "google-chrome"
      "obsidian"
    ];
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };

  # Spotlight indexing is disabled by default on the data volume on macOS; re-enable it declaratively
  system.activationScripts.extraActivation.text = ''
    mdutil -i on /System/Volumes/Data > /dev/null
  '';

  system.stateVersion = 6;

  nixpkgs.hostPlatform = "aarch64-darwin";
}
