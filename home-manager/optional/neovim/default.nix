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
      nvim-dap
      nvim-web-devicons
      telescope-nvim
      nvim-lspconfig
      

      {
        plugin = nvim-config-local;
	type = "lua";
	config = ''
	  require('config-local').setup {
            -- Default options (optional)

            -- Config file patterns to load (lua supported)
            config_files = { ".nvim.lua", ".nvimrc", ".exrc" },

            -- Where the plugin keeps files data
            hashfile = vim.fn.stdpath("data") .. "/config-local",

            autocommands_create = true, -- Create autocommands (VimEnter, DirectoryChanged)
            commands_create = true,     -- Create commands (ConfigLocalSource, ConfigLocalEdit, ConfigLocalTrust, ConfigLocalDeny)
            silent = false,             -- Disable plugin messages (Config loaded/denied)
            lookup_parents = false,     -- Lookup config files in parent directories
          }
	'';
      }
      {
        plugin = nvim-tree-lua;
	type = "lua";
	config = ''
          require("nvim-tree").setup()

          local builtin = require('telescope.builtin')

          vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
	'';
      }
      {
        plugin = nvim-dap-go;
	type = "lua";
	config = ''
	  require("dap-go").setup()
	'';
      }
      {
        plugin = nvim-dap-ui;
	type = "lua";
	config = ''
	  require("dapui").setup()
	'';
      }
    ];

    extraConfig = ''
      set number relativenumber
    '';

    extraLuaConfig = ''
      -- disable netrw
      vim.g.mapleader = ","
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      local ui = require "dapui"
      local dap = require "dap"

      dap.listeners.before.attach.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        ui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        ui.close()
      end
    '';
  };
}
