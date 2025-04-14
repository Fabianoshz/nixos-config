{ pkgs, lib, ... }:
{
  home.stateVersion = "24.11";

  imports = [
    ./homebrew.nix
    ./git.nix
    ./ssh.nix

    ../../../optional/zsh/default.nix
    ../../../optional/neovim/default.nix
  ];

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "obsidian"
        "google-chrome"
        "spotify"
      ];
    };
  };

  home.username = "fabiano";
  home.homeDirectory = "/Users/fabiano";

  # home.shellAliases = {
  #   kubelogin = "kubectl-oidc_login";
  # };

  home.packages = [
    pkgs.awscli2
    pkgs.aws-iam-authenticator
    pkgs.ssm-session-manager-plugin

    pkgs.kubectl
    pkgs.kustomize
    pkgs.kubernetes-helm
    pkgs.kubelogin-oidc
    pkgs.stern

    pkgs.docker

    pkgs.dbeaver-bin
    pkgs.colordiff
    pkgs.colima
    pkgs.gh
    pkgs.grpcurl
    pkgs.kubectx
    pkgs.obsidian
    # pkgs.spotify
    pkgs.tmux
    pkgs.bash
    pkgs.dig
    pkgs.git
    pkgs.htop
    pkgs.google-chrome

    # Temp
    pkgs.go
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
