-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Toggle Neo-tree with leader-k for current directory
vim.keymap.set('n', '<leader>k', function()
  require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
end, { desc = 'Toggle Neo-tree (cwd)' })





