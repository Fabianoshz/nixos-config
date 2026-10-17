{ pkgs, lib, inputs, ... }:
{
  home.stateVersion = "25.05";

  imports = [
    ./firefox.nix
    ./homebrew.nix
    ./iterm2.nix
    ./syncthing.nix

    ../../../optional/git/default.nix
    ../../../optional/neovim/default.nix
    ../../../optional/opencode/default.nix
    ../../../optional/zsh/default.nix
  ];

  home.username = lib.mkForce "fabiano";
  home.homeDirectory = lib.mkForce "/Users/fabiano";
  home.sessionVariables = {
    SYSTEMD_EDITOR = "nvim";
    EDITOR = "nvim";
  };

  home.packages = [
    pkgs.awscli2
    pkgs.bash
    pkgs.dbeaver-bin
    pkgs.dig
    pkgs.firefox
    pkgs.git
    pkgs.htop
    pkgs.keepassxc
    pkgs.ssm-session-manager-plugin

    pkgs.unstable.opencode
    pkgs.unstable.opencode-desktop
    pkgs.unstable.container
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  services.home-manager.autoExpire = {
    enable = true;
    timestamp = "-30 days";
    frequency = "weekly";
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "-d";
  };
}
