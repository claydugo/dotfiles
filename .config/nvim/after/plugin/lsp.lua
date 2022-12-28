local capabilities = require'cmp_nvim_lsp'.default_capabilities(vim.lsp.protocol.make_client_capabilities())
local on_init = function(client)
    client.config.flags = {}
    if client.config.flags then
      client.config.flags.allow_incremental_sync = true
      client.config.flags.debounce_text_changes = 200
    end
end
local lspconfig = require'lspconfig'
--
-- even though this seems to ensure install
-- in :checkhealth
-- I had to run :MasonInstall pyright
-- on fresh dotfiles pull
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "pyright", "sumneko_lua", "bashls" }
})

lspconfig.pyright.setup{capabilities = capabilities, on_init = on_init;}
lspconfig.sumneko_lua.setup{capabilities = capabilities, on_init = on_init;}
-- npm i -g bash-language-server
lspconfig.bashls.setup{capabilities = capabilities, on_init = on_init;}
