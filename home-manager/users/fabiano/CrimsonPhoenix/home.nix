{ pkgs, lib, ... }:
{
  home.stateVersion = "24.11";

  imports = [
    ./homebrew.nix
    ./syncthing.nix
    ./firefox.nix

    ../../../optional/zsh/default.nix
    ../../../optional/git/default.nix
    ../../../optional/neovim/default.nix
  ];

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
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
    pkgs.keepassxc
    pkgs.obsidian
    pkgs.ssm-session-manager-plugin
    pkgs.tmux
    pkgs.bash
    pkgs.dig
    pkgs.git
    pkgs.htop
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
