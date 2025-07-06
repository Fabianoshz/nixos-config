{ pkgs, pkgs-unstable, lib, ... }:
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

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "claude-code"
        "discord"
        "obsidian"
      ];
    };
  };

  home.username = "fabiano";
  home.homeDirectory = "/Users/fabiano";
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
    pkgs.keepassxc
    pkgs.obsidian
    pkgs.ssm-session-manager-plugin
    pkgs.tmux
    pkgs.utm

    pkgs-unstable.claude-code
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
