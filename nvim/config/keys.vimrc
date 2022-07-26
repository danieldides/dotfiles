" Set a map leader for more key combos
let mapleader = ','

nmap <silent> <leader>k :NvimTreeToggle<CR>

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

" LspSaga
" Use K to show documentation in preview window
nnoremap <silent> K <cmd>lua require('lspsaga.hover').render_hover_doc()<CR>
" Show signature
nnoremap <silent> gs <cmd>lua require('lspsaga.signaturehelp').signature_help()<CR>
" Cleaner rename
nnoremap <leader>s <cmd>lua require('lspsaga.rename').rename()<CR>

"map <c-p> to manually trigger completion
imap <silent> <c-p> <Plug>(completion_trigger)

" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Formatter
nnoremap <silent> <leader>F :Format<CR>

" Find files using Telescope 
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" LSP
nnoremap <leader>p = <cmd>lua vim.diagnostic.goto_prev()<CR>
nnoremap <leader>n = <cmd>lua vim.diagnostic.goto_next()<CR>
nnoremap <leader>j = <cmd>Telescope lsp_dynamic_workspace_symbols<CR>
" nnoremap <leader>i = <cmd>Telescope lsp_implementations<CR>
" nnoremap <leader>a = <cmd>Telescope lsp_code_actions<CR>

" When text is wrapped, move by terminal rows, not lines, unless a count is provided
noremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
noremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')

