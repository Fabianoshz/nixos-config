{ config, pkgs, lib, ... }:
{
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";

    initExtra = ''
      # Arrow keys
      bindkey "^[[C" vi-forward-char
      bindkey "^[[D" vi-backward-char
      bindkey "^[[A" up-line-or-history
      bindkey "^[[B" down-line-or-history

      # Ctrl keys
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word

      # Alt keys
      bindkey "^[[1;3C" forward-word
      bindkey "^[[1;3D" backward-word

      # Ctrl + Backspace
      bindkey "^H" backward-delete-word

      bindkey "^R" history-incremental-search-backward

      if [ -z "$TMUX" ] && command -v tmux > /dev/null ; then
        tmux attach -t TMUX || tmux new -s TMUX
      fi
    '';

    shellAliases = {
      ll = "ls -l";
    };

    history = {
      size = 10000000;
      path = "${config.xdg.dataHome}/zsh/history";
      extended = true;
    };

    completionInit = "autoload -U compinit && compinit -d \"$XDG_CACHE_HOME\"/zsh/zcompdump-\"$ZSH_VERSION\"";

    plugins = [
      {
        name = "zsh-autosuggestions";
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
        src = pkgs.zsh-autosuggestions;
      }
      {
        name = "powerlevel10k";
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        src = pkgs.zsh-powerlevel10k;
      }
      {
        name = "powerlevel10k-config";
        src = lib.cleanSource ./configs/p10k-config;
        file = "p10k.zsh";
      }
      {
        name = "zsh-nix-shell";
        file = "share/zsh-nix-shell/nix-shell.plugin.zsh";
        src = pkgs.zsh-nix-shell;
      }
      {
        name = "zsh-syntax-highlighting";
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
        src = pkgs.zsh-syntax-highlighting;
      }
    ];
  };

  programs.tmux = {
    enable = true;
    keyMode = "emacs";
    terminal = "screen-256color";
    shortcut = "a";
    extraConfig = ''
      set -g mouse on
      set -g base-index 1
      setw -g pane-base-index 1

      tmux_conf_theme_left_separator_main='\uE0B0'
      tmux_conf_theme_left_separator_sub='\uE0B1'
      tmux_conf_theme_right_separator_main='\uE0B2'
      tmux_conf_theme_right_separator_sub='\uE0B3'
    '';
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
