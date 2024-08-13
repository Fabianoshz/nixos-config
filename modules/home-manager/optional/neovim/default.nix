{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;

    plugins = with pkgs.vimPlugins; [
      nvim-tree-lua
      gitsigns-nvim
      telescope-nvim
    ];
  };
}
