{ pkgs, pkgs-unstable, lib, ... }:
{
  home.stateVersion = "25.05";

  imports = [
    ./homebrew.nix
    ./syncthing.nix
    ./firefox.nix

    ../../../optional/claude-md/default.nix
    ../../../optional/zsh/default.nix
    ../../../optional/git/default.nix
    ../../../optional/neovim/default.nix
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
    pkgs.dbeaver-bin
    pkgs.discord
    # pkgs.keepassxc # Waiting for: https://github.com/NixOS/nixpkgs/pull/411811
    pkgs.obsidian
    pkgs.ssm-session-manager-plugin
    pkgs.tmux
    pkgs.bash
    pkgs.dig
    pkgs.git
    pkgs.htop
    pkgs.utm
    pkgs.firefox

    pkgs-unstable.claude-code
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
