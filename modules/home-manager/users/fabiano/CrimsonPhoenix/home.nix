{ pkgs, lib, ... }:
{
  home.stateVersion = "24.11";

  imports = [
    ../common.nix
    ./homebrew.nix
    ./syncthing.nix

    ../../../core/zsh/default.nix
    ../../../optional/git/default.nix
    ../../../optional/neovim/default.nix
    ../../../optional/vscode/default.nix
  ];

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "discord"
        "obsidian"
        "spotify"
        "vscode-extension-github-copilot"
      ];
    };
  };

  home.username = "fabiano";
  home.homeDirectory = "/Users/fabiano";

  home.packages = [
    pkgs.awscli2
    pkgs.dbeaver-bin
    pkgs.discord
    pkgs.keepassxc
    pkgs.obsidian
    pkgs.ssm-session-manager-plugin
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
