{ pkgs, pkgs-unstable, lib, ... }:
{
  home.stateVersion = "25.05";

  imports = [
    ./git.nix
    ./homebrew.nix
    ./ssh.nix

    ../../../optional/claude-md/default.nix
    ../../../optional/neovim/default.nix
    ../../../optional/zsh/default.nix
  ];

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "claude-code"
        "google-chrome"
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
    pkgs.aws-iam-authenticator
    pkgs.awscli2
    pkgs.bash
    pkgs.colima
    pkgs.colordiff
    pkgs.coreutils
    pkgs.coreutils-prefixed
    pkgs.dbeaver-bin
    pkgs.delve
    pkgs.dig
    pkgs.docker
    pkgs.gh
    pkgs.git
    pkgs.go
    pkgs.google-chrome
    pkgs.grpcurl
    pkgs.htop
    pkgs.insomnia
    pkgs.kubectl
    pkgs.kubectx
    pkgs.kubelogin-oidc
    pkgs.kubernetes-helm
    pkgs.kustomize
    pkgs.obsidian
    pkgs.openjdk
    pkgs.ssm-session-manager-plugin
    pkgs.stern
    pkgs.tmux

    pkgs-unstable.claude-code
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
