local M = {
    "neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
        { "williamboman/mason.nvim",
            cmd = 'Mason',
            build = ':MasonUpdate'
        },
		{ "williamboman/mason-lspconfig.nvim" },
		{ "hrsh7th/nvim-cmp" },
		{ "hrsh7th/cmp-buffer" },
		{ "hrsh7th/cmp-path" },
		{ "saadparwaiz1/cmp_luasnip" },
		{ "hrsh7th/cmp-nvim-lsp" },
		{ "hrsh7th/cmp-nvim-lua" },
		{ "zbirenbaum/copilot-cmp" },
		{ "folke/neodev.nvim" },

		{ "L3MON4D3/LuaSnip" },
		{ "rafamadriz/friendly-snippets" },

        { "RRethy/vim-illuminate" },
	},
}

function M.config()
	require("mason").setup()
    local langservers = { 'pyright', 'ruff_lsp', 'bashls', 'lua_ls', 'rust_analyzer'}
	require("mason-lspconfig").setup({
		ensure_installed = langservers,
    })

	local lspconfig = require("lspconfig")
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    local illuminate = require('illuminate')
    local on_attach = function(client) illuminate.on_attach(client) end
    -- was nice but just too slow
    -- lspconfig.pylsp.setup({
    --   capabilities = capabilities,
    --   on_attach = on_attach,
    --   settings = {
    --     pylsp = {
    --       plugins = {
    --         ruff = { enabled = false },
    --         autopep8 = { enabled = false },
    --         flake8 = { enabled = false },
    --         mccabe = { enabled = false },
    --         pycodestyle = { enabled = false },
    --         pydocstyle = { enabled = false },
    --         pyflakes = { enabled = false },
    --         pylint = { enabled = false },
    --         yapf = { enabled = false },
    --       },
    --     },
    --   },
    -- })
    --
    for _, langserver in ipairs(langservers) do
        lspconfig[langserver].setup({
            capabilities = capabilities,
            on_attach = on_attach,
            single_file_support = true,
        })
    end

	require("neodev").setup()
	local cmp = require("cmp")
	local has_copilot, copilot_cmp = pcall(require, "copilot_cmp.comparators")
	local has_copilot_suggestion, copilot_suggestion = pcall(require, "copilot.suggestion")
    if has_copilot then
      require("copilot_cmp").setup()
    end
	local luasnip = require("luasnip")
    require("luasnip").filetype_extend("python", { "pydoc", "python", "debug" })


	cmp.setup({
		mapping = {
			["<C-d>"] = cmp.mapping.scroll_docs(-4),
			["<C-f>"] = cmp.mapping.scroll_docs(4),
			["<C-Space>"] = cmp.mapping.complete(),
			["<C-e>"] = cmp.mapping.abort(),
			["<CR>"] = cmp.mapping.confirm({ select = true }),
			["<Tab>"] = cmp.mapping(function(fallback)
				if has_copilot_suggestion and copilot_suggestion.is_visible() then
					require("copilot.suggestion").accept()
				elseif cmp.visible() then
					cmp.confirm({ select = true })
				else
					fallback()
				end
			end, {
				"i",
				"s",
			}),
			["<S-Tab>"] = cmp.mapping(function()
				if cmp.visible() then
					cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
				end
			end, {
				"i",
				"s",
			}),
			["<C-j>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "s" }),
			["<C-k>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "s" }),
			["<Down>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "s" }),
			["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "s" }),
		},
		sources = {
			{ name = "copilot", group_index = 2 },
			{ name = "nvim_lsp", group_index = 2 },
			{ name = "buffer", group_index = 2 },
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
		snippet = {
			expand = function(args)
				luasnip.lsp_expand(args.body)
			end,
		},
	})
	vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
	vim.keymap.set("n", "<leader>eq", vim.diagnostic.goto_prev)
	vim.keymap.set("n", "<leader>ee", vim.diagnostic.goto_next)
end

return M
