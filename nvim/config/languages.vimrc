let g:python_host_prog = "/home/daniel/Projects/env/nvim2/bin/python"
let g:python3_host_prog = "/home/daniel/Projects/env/nvim3/bin/python"


let g:go_def_mapping_enabled = 0
let g:go_fmt_command = "goimports"

let g:ale_linters = {
      \   'python': ['flake8', 'pylint'],
      \   'javascript': ['eslint'],
      \}

let g:ale_fixers = {
      \    'python': ['black'],
      \}

let filepath = expand('%:p:h')
if match(filepath, 'some-project-name') != -1
    let b:ale_fix_on_save = 1
endif


nmap <F10> :ALEFix<CR>
let g:ale_fix_on_save = 1
