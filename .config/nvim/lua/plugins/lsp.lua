local M = {
	"williamboman/mason.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		{ "williamboman/mason-lspconfig.nvim" },
		{ "neovim/nvim-lspconfig" },

		{ "hrsh7th/nvim-cmp" },
		{ "hrsh7th/cmp-buffer" },
		{ "hrsh7th/cmp-path" },
		{ "saadparwaiz1/cmp_luasnip" },
		{ "hrsh7th/cmp-nvim-lsp" },
		{ "hrsh7th/cmp-nvim-lua" },
		{ "zbirenbaum/copilot-cmp" },
		{ "folke/neodev.nvim" },

		-- Snippets
		{ "L3MON4D3/LuaSnip" },
		{ "rafamadriz/friendly-snippets" },
	},
}

function M.config()
	require("mason").setup()
	require("mason-lspconfig").setup({
		ensure_installed = { "pyright", "ruff_lsp", "lua_ls", "rust_analyzer", "bashls" },
	})
	-- https://github.com/neovim/neovim/issues/23291#issuecomment-1523243069
	-- https://github.com/neovim/neovim/pull/23500#issuecomment-1585986913
	-- pyright asks for every file in every directory to be watched,
	-- so for large projects that will necessarily turn into a lot of polling handles being created.
	-- sigh
	local ok, wf = pcall(require, "vim.lsp._watchfiles")
	if ok then
		wf._watchfunc = function()
			return function() end
		end
	end

	local lspconfig = require("lspconfig")
	lspconfig.pyright.setup({})
	lspconfig.ruff_lsp.setup({})
	lspconfig.lua_ls.setup({})
	lspconfig.bashls.setup({})
	lspconfig.rust_analyzer.setup({})

	require("neodev").setup()
	local cmp = require("cmp")
	local has_copilot, copilot_cmp = pcall(require, "copilot_cmp.comparators")
	local has_copilot_suggestion, copilot_suggestion = pcall(require, "copilot.suggestion")
    if has_copilot then
      require("copilot_cmp").setup()
    end
	local luasnip = require("luasnip")

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
