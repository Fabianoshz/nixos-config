{ pkgs, lib, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    enableUpdateCheck = true;

    extensions = with pkgs.vscode-extensions; [
      pkgs.vscode-extensions.arrterian.nix-env-selector
      pkgs.vscode-extensions.bbenoist.nix
      pkgs.vscode-extensions.github.github-vscode-theme
      pkgs.vscode-extensions.golang.go
      pkgs.vscode-extensions.hashicorp.terraform
      pkgs.vscode-extensions.jnoortheen.nix-ide
      pkgs.vscode-extensions.rust-lang.rust-analyzer
      pkgs.vscode-extensions.vscodevim.vim
      pkgs.vscode-extensions.github.copilot
      # Only available on unstable :(
      # pkgs.vscode-extensions.biomejs.biome
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "hcl";
        publisher = "hashicorp";
        version = "0.3.2";
        sha256 = "cxF3knYY29PvT3rkRS8SGxMn9vzt56wwBXpk2PqO0mo=";
      }
      {
        name = "vscode-intelephense-client";
        publisher = "bmewburn";
        version = "1.11.2";
        sha256 = "sha256-CnKuqKpW79L7ARtTkj3zPUnvVFKrih/gZW7ORU8HIis=";
      }
      {
        name = "php-namespace-resolver";
        publisher = "MehediDracula";
        version = "1.1.9";
        sha256 = "sha256-YgUxkaWuVxw7fgIiL7oZJDr8OX9bTy9gv9M8jXTXHbs=";
      }
    ];

    userSettings = {
      "editor.fontFamily" = "'Fira Code'";
      "editor.inlineSuggest.enabled" = true;
      "editor.lineHeight" = 20;
      "editor.lineNumbers" = "relative";
      "explorer.compactFolders" = false;
      "explorer.confirmDelete" = false;
      "explorer.confirmDragAndDrop" = false;
      "terminal.integrated.defaultProfile.linux" = "zsh";
      "terminal.integrated.profiles.linux" = {
        "zsh" = {
          "path" = "/run/current-system/sw/bin/zsh";
        };
        "bash" = null;
        "fish" = null;
        "tmux" = null;
        "pwsh" = null;
      };
      "update.showReleaseNotes" = false;
      "workbench.colorTheme" = "GitHub Dark Dimmed";
      "workbench.startupEditor" = "none";
    };
  };
}
