" All plugins must be called between begin/end
call plug#begin('~/.config/nvim/plugged')

" File browser
Plug 'scrooloose/nerdtree'

" Nice to haves
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'

" VCS 
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" Bling
Plug 'Yggdroot/indentLine'
Plug 'kien/rainbow_parentheses.vim'
Plug 'hoob3rt/lualine.nvim'

" Colorscheme
Plug 'joshdick/onedark.vim'

" Go
Plug 'fatih/vim-go'

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
