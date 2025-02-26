local M = {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		{ "williamboman/mason.nvim", cmd = "Mason", build = ":MasonUpdate" },
		{ "williamboman/mason-lspconfig.nvim" },
		{ "hrsh7th/nvim-cmp" },
		{ "hrsh7th/cmp-nvim-lsp" },
		{ "hrsh7th/cmp-nvim-lua" },
		{ "zbirenbaum/copilot-cmp" },
		{ "folke/lazydev.nvim" },
		{ "RRethy/vim-illuminate" },
	},
}

function M.config()
	require("mason").setup()
	-- https://github.com/microsoft/pyright/issues/4176#issuecomment-1310534474
	-- Do you have a pyrightconfig.json file in your home directory?
	-- If you open a file (as opposed to a directory / project / workspace / or whatever term neovim uses) pyright
	-- will scan up the directory hierarchy to find a pyrightconfig.json file.
	-- If it finds one, it assumes the opened file is part of a project rooted at that place in the directory hierarchy.
	-- fucking microsoft man...
	-- I had fswatch throwing so many errors despite
	-- fs.inotify.max_user_watches=10000000
	-- fs.inotify.max_queued_events=10000000
	-- in /etc/sysctl.conf
	-- I only realized the issue when :checkhealth reported
	-- that pyright was using $HOME as my project root_dir
	-- unlike all the other langservers
	-- I am constantly fixing odd edge case bugs for this langserver
	-- and having to install nodejs
	-- all because pylsp is so slow

	local langservers = {
		"pyright",
		-- 'ruff_lsp',
		"ruff",
		"wgsl_analyzer",
		"biome",
		"harper_ls",
		"bashls",
		"lua_ls",
		"rust_analyzer",
	}
	require("mason-lspconfig").setup({
		ensure_installed = langservers,
	})

	local lspconfig = require("lspconfig")
	local capabilities = require("cmp_nvim_lsp").default_capabilities()
	local illuminate = require("illuminate")

	capabilities.general = capabilities.general or {}
	capabilities.general.positionEncodings = { "utf-16" }

	local on_attach = function(client)
		illuminate.on_attach(client)
		if client.name == "ruff" then
			client.server_capabilities.hoverProvider = false
		end
	end
	for _, langserver in ipairs(langservers) do
		local config = {
			capabilities = capabilities,
			on_attach = on_attach,
			single_file_support = true,
		}
		if langserver == "pyright" then
			config.settings = {
				pyright = {
					disableOrganizeImports = true,
				},
				python = {
					analysis = {
						ignore = { "*" },
					},
				},
			}
		end
	  if langserver == "harper_ls" then
		config.settings = {
		  ["harper-ls"] = {
			-- userDictPath = "~/git/upstream/codespell/codespell_lib/data/dictionary.txt",
			userDictPath = vim.fn.stdpath("config") .. "/spell/en.utf-8.add",
			diagnosticSeverity = "hint",
			linters = {
				SentenceCapitalization = true,
				LongSentences = true,
			}
		  }
		}
	  end
		lspconfig[langserver].setup(config)
	end

	local cmp = require("cmp")
	local has_copilot, copilot_cmp = pcall(require, "copilot_cmp.comparators")
	local has_copilot_suggestion, copilot_suggestion = pcall(require, "copilot.suggestion")
	if has_copilot then
		require("copilot_cmp").setup()
	end

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
			-- Keep priority weight at 2 for much closer matches to appear above copilot
			-- set to 1 to make copilot always appear on top
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
	vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
	vim.keymap.set("n", "<leader>eq", vim.diagnostic.goto_prev)
	vim.keymap.set("n", "<leader>ee", vim.diagnostic.goto_next)

	-- https://github.com/wgsl-analyzer/wgsl-analyzer
	vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	  pattern = "*.wgsl",
	  callback = function()
		vim.bo.filetype = "wgsl"
	  end,
	})
end

return M
