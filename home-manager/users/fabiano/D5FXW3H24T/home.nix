{ pkgs, lib, inputs, ... }:
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

  home.username = lib.mkForce "fabiano";
  home.homeDirectory = lib.mkForce "/Users/fabiano";
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
    pkgs.golint
    pkgs.google-chrome
    pkgs.grpcurl
    pkgs.htop
    pkgs.insomnia
    pkgs.iterm2
    pkgs.kubectl
    pkgs.kubectx
    pkgs.kubelogin-oidc
    pkgs.kubernetes-helm
    pkgs.kustomize
    pkgs.obsidian
    pkgs.openjdk
    pkgs.protobuf
    pkgs.protoc-gen-go
    pkgs.protoc-gen-go-grpc
    pkgs.ssm-session-manager-plugin
    pkgs.stern
    pkgs.tmux

    pkgs.unstable.claude-code
    pkgs.unstable.container
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
