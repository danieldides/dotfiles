lua << EOF
-- LSP 
require'lspconfig'.pyright.setup{on_attach=require'completion'.on_attach}
require'lspconfig'.gopls.setup{}
require'lspconfig'.tsserver.setup{on_attach=require'completion'.on_attach}

-- TreeSitter
require'nvim-treesitter.configs'.setup {
  ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  ignore_install = { }, -- List of parsers to ignore installing
  highlight = {
    enable = true,              -- false will disable the whole extension
    disable = { },  -- list of language that will be disabled
  },
}


-- Formatter
require('formatter').setup({
  logging = false,
  filetype = {
    javascript = {
       function()
          return {
            exe = "prettier",
            args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0), '--single-quote'},
            stdin = true
          }
        end
    },
    typescript = {
       function()
          return {
            exe = "prettier",
            args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0), '--single-quote'},
            stdin = true
          }
        end
    }

  }
})

EOF

nnoremap <silent> <leader>f :Format<CR>

"" vim.api.nvim_exec([[
"" augroup FormatAutogroup
""   autocmd!
""   autocmd BufWritePost *.js,*ts,*jsx,*tsx FormatWrite
"" augroup END
"" ]], true)
