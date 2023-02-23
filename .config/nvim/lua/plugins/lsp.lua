local M = {
  'VonHeikemen/lsp-zero.nvim',
  event = "BufReadPre",
  dependencies = {
    -- LSP Support
    {'neovim/nvim-lspconfig'},
    {'williamboman/mason.nvim'},
    {'williamboman/mason-lspconfig.nvim'},

    -- Autocompletion
    {'hrsh7th/nvim-cmp'},
    {'hrsh7th/cmp-buffer'},
    {'hrsh7th/cmp-path'},
    {'saadparwaiz1/cmp_luasnip'},
    {'hrsh7th/cmp-nvim-lsp'},
    {'hrsh7th/cmp-nvim-lua'},

    -- Snippets
    {'L3MON4D3/LuaSnip'},
    {'rafamadriz/friendly-snippets'},
  }
}

function M.config()
    local lsp = require('lsp-zero')
    lsp.preset({
        name = 'recommended',
        suggest_lsp_servers = false,
    })
    lsp.ensure_installed({
        'pyright',
        -- 'sumneko_lua',
        -- 'bashls',
        -- 'rust_analyzer',
        -- 'ruff-lsp',
    })
    lsp.setup()
    local cmp = require'cmp'
    cmp.setup({
        mapping = {
            ['<C-d>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.abort(),
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
            ['<Tab>'] = cmp.mapping.confirm({ select = true }),
            ['<C-j>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's' }),
            ['<C-k>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 's' }),
        },
        sources = {
            { name = 'nvim_lsp' },
            { name = 'buffer' },
        }
    })
    vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
    vim.keymap.set('n', '<leader>eq', vim.diagnostic.goto_prev)
    vim.keymap.set('n', '<leader>ee', vim.diagnostic.goto_next)
end

return M
