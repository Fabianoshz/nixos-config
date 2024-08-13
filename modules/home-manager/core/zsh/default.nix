{ lib, config, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";

    initExtra = ''
      bindkey ";5D" backward-word
      bindkey ";5C" forward-word

      bindkey ";3D" backward-word
      bindkey ";3C" forward-word
    '';

    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch";
    };

    history = {
      size = 10000000;
      path = "${config.xdg.dataHome}/zsh/history";
    };

    completionInit = "autoload -U compinit && compinit -d \"$XDG_CACHE_HOME\"/zsh/zcompdump-\"$ZSH_VERSION\"";

    plugins = [
      {
        name = "powerlevel10k-config";
        src = lib.cleanSource ./configs/p10k-config;
        file = "p10k.zsh";
      }
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.8.0";
          sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
        };
      }      
    ];

    zplug = {
      enable = true;
      zplugHome = "${config.xdg.dataHome}/zplug";
      plugins = [
        { name = "zsh-users/zsh-autosuggestions"; }
        { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; }
      ];
    };

    sessionVariables = {
      DOCKER_CONFIG = "${config.xdg.configHome}/docker";
      ELECTRUMDIR = "${config.xdg.dataHome}/electrum";
      GNUPGHOME = "${config.xdg.dataHome}/gnupg";
      KUBECACHEDIR = "${config.xdg.cacheHome}/kube";
      KUBECONFIG = "${config.xdg.configHome}/kube/kubeconfig";
      LESSHISTFILE = "${config.xdg.cacheHome}/less/history";
      MINIKUBE_HOME = "${config.xdg.dataHome}/minikube";
      NPM_CONFIG_CACHE = "${config.xdg.cacheHome}/npm";
      NPM_CONFIG_TMP = "$XDG_RUNTIME_DIR/npm";
      NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm/config";
      RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
      # SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent.socket";
      # VSCODE_EXTENSIONS = "${config.xdg.dataHome}/VSCodium/extensions";
      WINEPREFIX = "${config.xdg.dataHome}/wine";
      XCOMPOSECACHE = "${config.xdg.cacheHome}/X11/xcompose";
      ZPLUG_HOME = "${config.xdg.dataHome}/zplug";
    };
  };
}
