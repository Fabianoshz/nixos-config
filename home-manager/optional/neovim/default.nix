{ pkgs, lib, ... }:
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraPackages = [ ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

    plugins = with pkgs.vimPlugins; [
      gitsigns-nvim
      nvim-web-devicons

      {
        plugin = nvim-treesitter;
        type = "lua";
        config = ''
          require('nvim-treesitter.configs').setup({
            highlight = {
              enable = true,
            },
            indent = {
              enable = true,
            },
          })
        '';
      }
      nvim-treesitter-parsers.go
      nvim-treesitter-parsers.nix
      nvim-treesitter-parsers.terraform
      nvim-treesitter-parsers.hcl
      nvim-treesitter-parsers.bash
      nvim-treesitter-parsers.python
      nvim-treesitter-parsers.yaml

      # Debugger
      nvim-dap

      # LSP
      nvim-lspconfig

      # Color scheme
      tokyonight-nvim

      telescope-live-grep-args-nvim

      {
        plugin = telescope-nvim;
        type = "lua";
        config = ''
                    require("telescope").setup()
                    require("telescope").load_extension("live_grep_args")

                    local builtin = require('telescope.builtin')
                    local live_grep_args = require("telescope").extensions.live_grep_args

                    vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
                    vim.keymap.set('n', '<leader>fg', live_grep_args.live_grep_args, { desc = 'Live grep with args' })
                    vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = 'Lists previously open files' })
                    vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Lists previously open buffers' })
          	'';
      }
      {
        plugin = nvim-tree-lua;
        type = "lua";
        config = ''
                    local function on_attach(bufnr)
                      local api = require "nvim-tree.api"
                      api.config.mappings.default_on_attach(bufnr)
                    end

                    require("nvim-tree").setup {
                      on_attach = on_attach,
                    }

                    -- Toggle NvimTree with Ctrl+B
                    vim.keymap.set('n', '<C-b>', '<cmd>NvimTreeToggle<cr>', { desc = 'Toggle NvimTree' })
                    -- Find current file in NvimTree
                    vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeFindFile<cr>', { desc = 'Find file in NvimTree' })
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
      colorscheme tokyonight-night
    '';

    extraLuaConfig = ''
      -- Disable netrw
      vim.g.mapleader = ","
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      -- LSP stuff
      vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'LSP actions',
        callback = function(event)
          local opts = {buffer = event.buf}

          -- these will be buffer-local keybindings
          -- because they only work if you have an active language server

          vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
          vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
          vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
          vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
          vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
          vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
          vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
          vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
          vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
          vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
        end
      })

      -- Debugger stuff

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
