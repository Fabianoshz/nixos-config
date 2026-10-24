{ pkgs, lib, inputs, ... }:
let
  tasksOrg = pkgs.stdenvNoCC.mkDerivation {
    pname = "tasks-org";
    version = "15.13.0";
    src = pkgs.fetchzip {
      url = "https://update.tasks.org/tasks-org-15.13.0-mac-aarch64.zip";
      hash = "sha256-vboMoOalElmxQYKzfmbXntt1fuBLxXnUhEJbpp7dNhw=";
    };
    installPhase = ''
      runHook preInstall
      mkdir -p $out/Applications/Tasks.org.app
      cp -R Contents $out/Applications/Tasks.org.app/
      runHook postInstall
    '';
  };
in
{
  home.stateVersion = "25.05";

  imports = [
    inputs.mac-app-util.homeManagerModules.default
    ./firefox.nix
    ./homebrew.nix
    ./syncthing.nix

    ../../../optional/git/default.nix
    ../../../optional/iterm2/default.nix
    ../../../optional/neovim/default.nix
    ../../../optional/opencode/default.nix
    ../../../optional/thunderbird/default.nix
    ../../../optional/zsh/default.nix
  ];

  home.username = lib.mkForce "fabiano";
  home.homeDirectory = lib.mkForce "/Users/fabiano";
  home.sessionVariables = {
    SYSTEMD_EDITOR = "nvim";
    EDITOR = "nvim";
  };

  xdg.configFile."opencode" = {
    source = ./opencode;
    recursive = true;
  };

  home.packages = [
    pkgs.awscli2
    pkgs.bash
    pkgs.dbeaver-bin
    pkgs.dig
    pkgs.firefox
    pkgs.git
    pkgs.htop
    pkgs.keepassxc
    pkgs.ssm-session-manager-plugin
    pkgs.thunderbird
    tasksOrg

    pkgs.unstable.opencode
    pkgs.unstable.opencode-desktop
    pkgs.unstable.container
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
