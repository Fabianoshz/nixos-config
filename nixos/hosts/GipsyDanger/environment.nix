{ pkgs, inputs, ... }:
{
  environment = {
    systemPackages = with pkgs; [
      # home-manager
      docker-machine-kvm2
      git
      libusb1
      vim
    ];

    sessionVariables = rec {
      CUDA_CACHE_PATH = "$XDG_CACHE_HOME/nv";
      GTK_IM_MODULE = "cedilla";
      QT_IM_MODULE = "cedilla";
      SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent";
      XCOMPOSECACHE = "$XDG_CACHE_HOME/X11/xcompose";
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_STATE_HOME = "$HOME/.local/state";
    };

    shells = with pkgs; [ zsh ];
  };
}
