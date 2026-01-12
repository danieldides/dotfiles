return {
  -- Theme configuration: Onedark Dark Mode
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "onedark",
    },
  },
  {
    "navarasu/onedark.nvim",
    priority = 1000,
    opts = {
      style = "dark",
    },
  },

  -- Use LazyVim's recommended LSP configuration
  -- Remove custom LSP servers and use LazyVim defaults
  {
    "LazyVim/LazyVim",
    opts = {
      -- LSP will be configured by LazyVim automatically
    },
  },

  -- Use LazyVim's recommended Treesitter configuration
  -- Remove custom treesitter languages and use LazyVim defaults
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Use LazyVim's default ensure_installed
      return opts
    end,
  },

  -- Use LazyVim's recommended neo-tree (already enabled by default)
  -- No need to explicitly configure neo-tree as LazyVim handles it

  -- Supermaven (AI assistant)
  {
    "supermaven-inc/supermaven-nvim",
    config = function()
      require("supermaven-nvim").setup({})
    end,
  },

  -- Go.nvim for Go development
  {
    "ray-x/go.nvim",
    dependencies = { -- optional packages
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup()
    end,
    event = { "CmdlineEnter" },
    ft = { "go", 'gomod' },
    build = ':lua require("go.install").update_all_sync()'
  },
}