{ pkgs, pkgs-mac-dbeaver, lib, ... }:
{
  imports = [
    ../common.nix
    ./homebrew.nix
  ];

  home.stateVersion = "24.05";

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "discord"
        "obsidian"
        "vscode-extension-github-copilot"
      ];
    };
  };

  home.username = "fabiano";
  home.homeDirectory = "/Users/fabiano";

  home.packages = [
    pkgs-mac-dbeaver.dbeaver-bin

    pkgs.awscli2
    pkgs.discord
    pkgs.keepassxc
    pkgs.obsidian
    pkgs.ssm-session-manager-plugin
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}