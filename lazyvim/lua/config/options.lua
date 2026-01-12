-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Leader key: keep ',' as specified
vim.g.mapleader = ','
vim.g.maplocalleader = ','

-- Custom options from your current config
vim.o.tabstop = 4
vim.o.maxmempattern = 500000

-- Disable relative line numbering
vim.opt.relativenumber = false

-- Show all characters including backticks in markdown
vim.opt.conceallevel = 0