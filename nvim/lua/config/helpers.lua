local helpers = {}

-- Stolen from https://github.com/mrnugget/vimconfig/blob/master/lua/lsp/helpers.lua
--	Taken from here: https://github.com/neovim/nvim-lspconfig/issues/115
helpers.goimports = function(wait_ms)
    local params = vim.lsp.util.make_range_params()
    params.context = {
        only = {"source.organizeImports"}
    }
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction",
                                            params, wait_ms)
    for _, res in pairs(result or {}) do
        for _, r in pairs(res.result or {}) do
            if r.edit then
                vim.lsp.util.apply_workspace_edit(r.edit)
            else
                vim.lsp.buf.execute_command(r.command)
            end
        end
    end

    vim.lsp.buf.formatting_sync()
end

return helpers