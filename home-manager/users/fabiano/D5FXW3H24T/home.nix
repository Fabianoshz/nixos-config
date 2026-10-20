{ pkgs, lib, inputs, ... }:
{
  home.stateVersion = "25.05";

  imports = [
    ./git.nix
    ./homebrew.nix
    ./ssh.nix

    ../../../optional/cursor/default.nix
    ../../../optional/iterm2/default.nix
    ../../../optional/neovim/default.nix
    ../../../optional/opencode/default.nix
    ../../../optional/zsh/default.nix
  ];

  home.username = lib.mkForce "fabiano";
  home.homeDirectory = lib.mkForce "/Users/fabiano";
  home.sessionVariables = {
    SYSTEMD_EDITOR = "nvim";
    EDITOR = "nvim";
    # cs self-updates to a generic build that defaults to sandboxes.cloud; pin Brex's server.
    CRAFTING_SANDBOX_SERVER_URL = "https://brex.sandboxes.site";
  };

  # Crafting CLI (cs) self-installs and self-updates here; not managed by nix.
  home.sessionPath = [ "$HOME/.crafting/sandbox/cli/current/bin" ];

  xdg.configFile."opencode" = {
    source = ./opencode;
    recursive = true;
  };

  home.packages = [
    pkgs.aws-iam-authenticator
    pkgs.awscli2
    pkgs.bash
    pkgs.colordiff
    pkgs.coreutils
    pkgs.coreutils-prefixed
    pkgs.dbeaver-bin
    pkgs.delve
    pkgs.dig
    pkgs.docker
    pkgs.fluxcd
    pkgs.gh
    pkgs.git
    pkgs.go
    pkgs.golint
    pkgs.grpcurl
    pkgs.htop
    pkgs.insomnia
    pkgs.kubeconform
    pkgs.kubectl
    pkgs.kubectx
    pkgs.kubelogin-oidc
    pkgs.kubernetes-helm
    pkgs.kustomize
    pkgs.nodejs
    pkgs.obsidian
    pkgs.openjdk
    pkgs.protobuf
    pkgs.protoc-gen-go
    pkgs.protoc-gen-go-grpc
    pkgs.ssm-session-manager-plugin
    pkgs.stern
    pkgs.temporal-cli
    pkgs.tmux

    pkgs.unstable.container
    pkgs.unstable.opencode
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  services.home-manager.autoExpire = {
    enable = true;
    timestamp = "-30 days";
    frequency = "weekly";
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "-d";
  };
}
