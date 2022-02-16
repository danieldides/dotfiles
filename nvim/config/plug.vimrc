" All plugins must be called between begin/end
call plug#begin('~/.config/nvim/plugged')

" File explorer
Plug 'kyazdani42/nvim-tree.lua'

" Nice to haves
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'folke/which-key.nvim'

" VCS 
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" Bling
Plug 'kien/rainbow_parentheses.vim'
Plug 'hoob3rt/lualine.nvim'
Plug 'kyazdani42/nvim-web-devicons' " for file icons
Plug 'lukas-reineke/indent-blankline.nvim'

" Colorscheme
Plug 'joshdick/onedark.vim'

" LSP
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/nvim-cmp'

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'glepnir/lspsaga.nvim'

Plug 'mhartington/formatter.nvim'

" Telescope
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make', 'branch': 'main' }

call plug#end()

filetype plugin indent on         
