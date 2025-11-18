{ pkgs, lib, inputs, ... }:
{
  home.stateVersion = "25.05";

  imports = [
    ./firefox.nix
    ./homebrew.nix
    ./syncthing.nix

    ../../../optional/claude-md/default.nix
    ../../../optional/git/default.nix
    ../../../optional/neovim/default.nix
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
    pkgs.discord
    pkgs.firefox
    pkgs.git
    pkgs.htop
    pkgs.iterm2
    pkgs.keepassxc
    pkgs.obsidian
    pkgs.ssm-session-manager-plugin
    pkgs.tmux
    pkgs.utm

    pkgs.unstable.claude-code
    pkgs.unstable.container
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
