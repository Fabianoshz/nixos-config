{ config, pkgs, lib, ... }:
{
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";

    initContent = ''
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
    '';

    shellAliases = {
      ll = "ls -l";
    };

    history = {
      size = 1000000000;
      save = 1000000000;
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
    plugins = with pkgs.tmuxPlugins; [
      resurrect
      continuum
    ];
    extraConfig = ''
      set -g mouse on
      set -g base-index 1
      setw -g pane-base-index 1

      set -g @left_sep "\uE0B0"
      set -g @left_sep_thin "\uE0B1"
      set -g @right_sep "\uE0B2"
      set -g @right_sep_thin "\uE0B3"

      # switch panes using Alt-arrow without prefix (Linux only) - no wrapping
      if-shell 'test "$(uname)" = "Linux"' {
        bind -n M-Left if -F '#{@pane-is-vim}' 'send-keys M-Left' 'if -F "#{pane_at_left}" "" "select-pane -L"'
        bind -n M-Right if -F '#{@pane-is-vim}' 'send-keys M-Right' 'if -F "#{pane_at_right}" "" "select-pane -R"'
        bind -n M-Up if -F '#{@pane-is-vim}' 'send-keys M-Up' 'if -F "#{pane_at_top}" "" "select-pane -U"'
        bind -n M-Down if -F '#{@pane-is-vim}' 'send-keys M-Down' 'if -F "#{pane_at_bottom}" "" "select-pane -D"'
      }

      # switch panes using Cmd-arrow without prefix (macOS only) - no wrapping
      if-shell 'test "$(uname)" = "Darwin"' {
        bind -n D-Left if -F "#{pane_at_left}" "" "select-pane -L"
        bind -n D-Right if -F "#{pane_at_right}" "" "select-pane -R"
        bind -n D-Up if -F "#{pane_at_top}" "" "select-pane -U"
        bind -n D-Down if -F "#{pane_at_bottom}" "" "select-pane -D"
      }

      # reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"

      # statusbar
      set -g status-left ""
      set -g status-position bottom
      set -g status-justify left
      set -g status-style 'fg=green'

      set -g status-left-length 10

      set -g status-right-style 'fg=black bg=yellow'
      set -g status-right '%Y-%m-%d %H:%M '
      set -g status-right-length 50

      setw -g window-status-separator ""

      setw -g window-status-current-style 'fg=black bg=green'
      setw -g window-status-current-format '#[fg=black,bg=green] #I #W #F#[fg=green,bg=black]#{@left_sep}'

      setw -g window-status-style 'fg=green bg=black'
      setw -g window-status-format '#[fg=green,bg=black] #I #[fg=white]#W #[fg=yellow]#F#[fg=black,bg=black]#{@left_sep}'

      setw -g window-status-bell-style 'fg=yellow bg=red bold'

      # messages
      set -g message-style 'fg=yellow bg=red bold'

      # tmux-resurrect settings
      set -g @resurrect-capture-pane-contents 'on'
      set -g @resurrect-strategy-vim 'session'
      set -g @resurrect-strategy-nvim 'session'

      # tmux-continuum settings
      set -g @continuum-restore 'on'
      set -g @continuum-save-interval '1'
    '';
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
