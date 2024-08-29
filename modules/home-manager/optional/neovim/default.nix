{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      nvim-tree-lua
      gitsigns-nvim
      telescope-nvim
    ];

    # TODO: add macro to quote strings
    extraConfig = ''

    '';
  };
}
