lua << EOF
-- python
require'lspconfig'.pyright.setup{on_attach=require'completion'.on_attach}

require'lspconfig'.gopls.setup{}

EOF
