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
    { "zbirenbaum/copilot-cmp" },

    -- Snippets
    {'L3MON4D3/LuaSnip'},
    {'rafamadriz/friendly-snippets'},
  }
}

local function has_words_before()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

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
    require'copilot_cmp'.setup()
    local has_copilot, copilot_cmp = pcall(require, "copilot_cmp.comparators")
    cmp.setup({
        mapping = {
            ['<C-d>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.abort(),
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
            -- ['<Tab>'] = cmp.mapping.confirm({ select = true }),
            ["<Tab>"] = cmp.mapping(
                function(fallback)
                    if require("copilot.suggestion").is_visible() then
                        require("copilot.suggestion").accept()
                    elseif cmp.visible() then
                        cmp.confirm({ select = true })
                    elseif has_words_before() then
                        cmp.complete()
                    else
                        fallback()
                    end
                end,
                {
                    "i",
                    "s",
                }),
            ["<S-Tab>"] = cmp.mapping(
                function()
                    if cmp.visible() then
                        cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
                    end
                end,
                {
                    "i",
                    "s",
                }),
            ['<C-j>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's' }),
            ['<C-k>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 's' }),
        },
        sources = {
            { name = "copilot", group_index = 2},
            { name = 'nvim_lsp', group_index = 2},
            { name = 'buffer', group_index = 2},
        },
        sorting = {
        --keep priority weight at 2 for much closer matches to appear above copilot
        --set to 1 to make copilot always appear on top
            priority_weight = 1,
                comparators = {
                cmp.config.compare.exact,
                has_copilot and copilot_cmp.prioritize or nil,
                has_copilot and copilot_cmp.score or nil,
                cmp.config.compare.offset,
                cmp.config.compare.score,
                cmp.config.compare.recently_used,
                cmp.config.compare.locality,
                cmp.config.compare.kind,
                cmp.config.compare.sort_text,
                cmp.config.compare.length,
                cmp.config.compare.order,
            },
        },
    })
    vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
    vim.keymap.set('n', '<leader>eq', vim.diagnostic.goto_prev)
    vim.keymap.set('n', '<leader>ee', vim.diagnostic.goto_next)
end

return M
