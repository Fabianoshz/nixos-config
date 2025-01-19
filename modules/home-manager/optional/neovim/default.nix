{ pkgs, lib, ... }:
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraPackages = [] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

    plugins = with pkgs.vimPlugins; [
      gitsigns-nvim
      harpoon2
      nvim-tree-lua
      nvim-web-devicons
      telescope-nvim
    ];

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
