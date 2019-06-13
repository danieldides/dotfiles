" All plugins must be called between begin/end
call plug#begin('~/.config/nvim/plugged')

" File browser
Plug 'scrooloose/nerdtree'

" Linters
" Plug 'scrooloose/syntastic'
Plug 'neomake/neomake'

" VCS 
Plug 'tpope/vim-fugitive'

" Fuzzy search
Plug 'ctrlpvim/ctrlp.vim'

" Bling
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'airblade/vim-gitgutter'
Plug 'https://github.com/vim-scripts/vim-svngutter'
Plug 'mhinz/vim-signify'

" Autocomplete
Plug 'Shougo/deoplete.nvim'
Plug 'zchee/deoplete-jedi'
Plug 'tpope/vim-surround'

" Tags?
" Plug 'fntlnz/atags.vim'
"Plug 'ludovicchabant/vim-gutentags'
Plug 'mileszs/ack.vim'

" Language spcific
" Clojure
Plug 'tpope/vim-fireplace'
Plug 'guns/vim-clojure-static'
Plug 'tpope/vim-classpath'
Plug 'luochen1990/rainbow'

" Go
Plug 'fatih/vim-go'
Plug 'zchee/deoplete-go', {'build': {'unix': 'make'}}

" JSX and React
Plug 'pangloss/vim-javascript'
" Plug 'mxw/vim-jsx'

" Plug 'vim-scripts/paredit.vim'
Plug 'kien/rainbow_parentheses.vim'

" Colorscheme
Plug 'joshdick/onedark.vim'

call plug#end()

filetype plugin indent on         
