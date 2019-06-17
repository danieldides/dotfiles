" All plugins must be called between begin/end
call plug#begin()

" File browser
Plug 'scrooloose/nerdtree'

" Linters
" Plug 'scrooloose/syntastic'
Plug 'neomake/neomake'

" VCS 
Plug 'tpope/vim-fugitive'

" Fuzzy search
Plug 'ctrlpvim/ctrlp.vim'

" Bling bling
Plug 'bling/vim-airline'
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

call plug#end()

filetype plugin indent on         

" set rtp+=/usr/lib/python3.5/site-packages/powerline/bindings/vim

"---------------------------FEATURES---------------------------------
"
" let g:syntastic_python_python_exec = '/usr/bin/python2'
let g:deoplete#enable_at_startup = 1
autocmd! BufWritePost * Neomake

let g:jsx_ext_required = 0 " Allow JSX in normal JS files


" autocmd BufWritePost * call atags#generate()

" deoplete settings
" autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
" autocmd CompleteDone * pclose
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"

" Set 'nocompatible' to ward off unexpected things that your distro might
" have made, as well as sanely reset options when re-sourcing .vimrc
set nocompatible
 
" Attempt to determine the type of a file based on its name and possibly its
" contents. Use this to allow intelligent auto-indenting for each filetype,
" and for plugins that are filetype specific.
filetype indent plugin on
 
" Enable syntax highlighting
syntax on

" Change colorscheme
set background=dark
set t_Co=256
" colorscheme base16-ocean
colorscheme onedark

"Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
"If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
"(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
if (empty($TMUX))
  if (has("nvim"))
    "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
  "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
  " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
  if (has("termguicolors"))
    set termguicolors
  endif
endif

" Reduce delay with airline in NVIMa
if ! has('gui_running')
    set ttimeoutlen=10
    augroup FastEscape
        autocmd!
        au InsertEnter * set timeoutlen=0
        au InsertLeave * set timeoutlen=1000
    augroup END
endif
 
" Vim with default settings does not allow easy switching between multiple files
" in the same editor window. Users can use multiple split windows or multiple
" tab pages to edit multiple files, but it is still best to enable an option to
" allow easier switching between files.
"
" One such option is the 'hidden' option, which allows you to re-use the same
" window and switch from an unsaved buffer without saving it first. Also allows
" you to keep an undo history for multiple files when re-using the same window
" in this way. Note that using persistent undo also lets you undo in multiple
" files even in the same window, but is less efficient and is actually designed
" for keeping undo history after closing Vim entirely. Vim will complain if you
" try to quit without saving, and swap files will keep you safe if your computer
" crashes.
set hidden
 
" Note that not everyone likes working this way (with the hidden option).
" Alternatives include using tabs or split windows instead of re-using the same
" window as mentioned above, and/or either of the following options:
" set confirm
" set autowriteall
 
" Better command-line completion
set wildmenu
 
" Show partial commands in the last line of the screen
set showcmd
 
" Highlight searches (use <C-L> to temporarily turn off highlighting; see the
" mapping of <C-L> below)
set hlsearch

" Use case insensitive search, except when using capital letters
set ignorecase
set smartcase
 
" Allow backspacing over autoindent, line breaks and start of insert action
set backspace=indent,eol,start
 
" When opening a new line and no filetype-specific indenting is enabled, keep
" the same indent as the line you're currently on. Useful for READMEs, etc.
set autoindent
 
" Stop certain movements from always going to the first character of a line.
" While this behaviour deviates from that of Vi, it does what most users
" coming from other editors would expect.
set nostartofline
 
" Display the cursor position on the last line of the screen or in the status
" line of a window
set ruler
 
" Always display the status line, even if only one window is displayed
set laststatus=2
 
" Instead of failing a command because of unsaved changes, instead raise a
" dialogue asking if you wish to save changed files.
set confirm
 
" Use visual bell instead of beeping when doing something wrong
set visualbell
 
" And reset the terminal code for the visual bell. If visualbell is set, and
" this line is also included, vim will neither flash nor beep. If visualbell
" is unset, this does nothing.
set t_vb=
 
" Enable use of the mouse for all modes
set mouse=a
 
" Set the command window height to 2 lines, to avoid many cases of having to
" "press <Enter> to continue"
set cmdheight=2
 
" Display line numbers on the left
set number
 
" Quickly time out on keycodes, but never time out on mappings
set notimeout ttimeout ttimeoutlen=200
 
" Use <F11> to toggle between 'paste' and 'nopaste'
set pastetoggle=<F11>
 
"-----------------------------INDENTATION SETTINGS--------------------------------
" If we're working with a Python, Haskell file, expand tabs to 4 spaces
au FileType python setlocal tabstop=4 expandtab shiftwidth=4 softtabstop=4
au FileType haskell setlocal tabstop=4 expandtab shiftwidth=4 softtabstop=4
au FileType markdown setlocal tabstop=4 expandtab shiftwidth=4 softtabstop=4
au FileType javascript setlocal tabstop=2 expandtab shiftwidth=2 softtabstop=2
au FileType json setlocal tabstop=2 expandtab shiftwidth=2 softtabstop=2
au FileType yaml setlocal tabstop=2 expandtab shiftwidth=2 softtabstop=2

" In python, highlight tabs (wow this will get annoying if I read a file with
" tab indentation...)
au FileType python setlocal list listchars=tab:>.,trail:.,extends:#,nbsp:.

" Indentation settings for using 4 spaces instead of tabs.
" Do not change 'tabstop' from its default value of 8 with this setup.
set shiftwidth=4
set softtabstop=4
set noexpandtab
 
" Indentation settings for using hard tabs for indent. Display tabs as
" four characters wide.
"set shiftwidth=4
set tabstop=4
set shiftround

"-----------------------------MAPPINGS-------------------------------
" Set a map leader for more key combos
let mapleader = ','

nmap <silent> <leader>k :NERDTreeToggle<cr>
nmap <silent> <leader>y :NERDTreeFind<cr>

" Generate tags with <Leader>T
" set statusline+=%{gutentags#statusline()}

" map <Leader>t :call atags#generate()<cr>


" Map C-hjkl to winmove

map <C-h> :call WinMove('h')<cr>
map <C-j> :call WinMove('j')<cr>
map <C-k> :call WinMove('k')<cr>
map <C-l> :call WinMove('l')<cr>

" Move over a window logically or create one if it does not exist

function! WinMove(key)
	let t:curwin = winnr()
	exec "wincmd ".a:key
	if (t:curwin == winnr())
		if (match(a:key, '[jk]'))
			wincmd v
		else
			wincmd s
		endif
		exec "wincmd ".a:key
	endif
endfunction

" Map Y to act like D and C, i.e. to yank until EOL, rather than act as yy,
" which is the default
map Y y$
 
" Map <C-L> (redraw screen) to also turn off search highlighting until the
" next search
" nnoremap <C-/> :nohl<CR><C-L>

" Escape will exit to Normal mode in terminals
tnoremap <Esc> <C-\><C-n>

" Navigate windows whether in a term or the editor with alt+hjkl
tnoremap <A-h> <C-\><C-n><C-w>h
tnoremap <A-j> <C-\><C-n><C-w>j
tnoremap <A-k> <C-\><C-n><C-w>k
tnoremap <A-l> <C-\><C-n><C-w>l
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l

" Tab navigation like Firefox.
nnoremap <C-S-tab> :tabprevious<CR>
nnoremap <C-tab>   :tabnext<CR>
nnoremap <C-t>     :tabnew<CR>
inoremap <C-S-tab> <Esc>:tabprevious<CR>i
inoremap <C-tab>   <Esc>:tabnext<CR>i
inoremap <C-t>     <Esc>:tabnew<CR>

let g:rainbow_active = 1 "0 if you want to enable it later via :RainbowToggle

" Search ignores case unless using capital letters
set ignorecase
set smartcase
