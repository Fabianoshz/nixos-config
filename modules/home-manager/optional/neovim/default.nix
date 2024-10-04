{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraPackages = [
      pkgs.nerdfonts
    ];

    plugins = with pkgs.vimPlugins; [
      nvim-tree-lua
      nvim-web-devicons
      gitsigns-nvim
      telescope-nvim
    ];

    # TODO: add macro to quote strings
    extraConfig = ''
      set number relativenumber
    '';

    extraLuaConfig = ''
      -- disable netrw
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      require("nvim-tree").setup()
    '';
  };
}
