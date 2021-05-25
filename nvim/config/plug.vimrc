" All plugins must be called between begin/end
call plug#begin('~/.config/nvim/plugged')

" File browser
Plug 'scrooloose/nerdtree'

" Nice to haves
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'

" Linters
Plug 'dense-analysis/ale'

" Autocomplete
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" VCS 
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" Fuzzy search
Plug 'ctrlpvim/ctrlp.vim'
Plug 'mileszs/ack.vim'

" Bling
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'Yggdroot/indentLine'
Plug 'kien/rainbow_parentheses.vim'

" Tags
" Plug 'liuchengxu/vista.vim'

" Colorscheme
Plug 'joshdick/onedark.vim'

" --- Language specific ---

" General
Plug 'sheerun/vim-polyglot'
let g:polygot_disabled = ["python"]

" Python
" Plug 'numirias/semshi', {'do': ':UpdateRemotePlugins'}

" Clojure
" Plug 'tpope/vim-fireplace'
" Plug 'guns/vim-clojure-static'
" Plug 'tpope/vim-classpath'
" 
" " Go
Plug 'fatih/vim-go'


call plug#end()

filetype plugin indent on         
