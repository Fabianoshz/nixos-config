{ pkgs, lib, ... }:
{
  home.stateVersion = "25.05";

  imports = [
    ./homebrew.nix
    ./git.nix
    ./ssh.nix

    ../../../optional/claude-md/default.nix
    ../../../optional/zsh/default.nix
    ../../../optional/neovim/default.nix
  ];

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "obsidian"
        "google-chrome"
        "claude-code"
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
    pkgs.aws-iam-authenticator
    pkgs.ssm-session-manager-plugin

    pkgs.kubectl
    pkgs.kustomize
    pkgs.kubernetes-helm
    pkgs.kubelogin-oidc
    pkgs.stern
    pkgs.coreutils
    pkgs.coreutils-prefixed

    pkgs.docker

    pkgs.dbeaver-bin
    pkgs.colordiff
    pkgs.colima
    pkgs.gh
    pkgs.grpcurl
    pkgs.kubectx
    pkgs.obsidian
    pkgs.tmux
    pkgs.bash
    pkgs.dig
    pkgs.git
    pkgs.htop
    pkgs.google-chrome
    pkgs.insomnia
    pkgs.go
    pkgs.delve
    pkgs.openjdk
    pkgs.claude-code
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
