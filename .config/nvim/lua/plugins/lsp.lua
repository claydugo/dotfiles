local M = {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		{ "williamboman/mason.nvim", cmd = "Mason", build = ":MasonUpdate" },
		{ "williamboman/mason-lspconfig.nvim" },
		{ "saghen/blink.cmp" },
		{ "RRethy/vim-illuminate" },
	},
}

function M.config()
	require("mason").setup()
	local langservers = {
		"ty",
		"ruff",
		"biome",
		"harper_ls",
		"bashls",
		"lua_ls",
		"rust_analyzer",
	}

	local lspconfig = require("lspconfig")
	local capabilities = require("blink.cmp").get_lsp_capabilities()
	local illuminate = require("illuminate")

	capabilities.general = capabilities.general or {}
	capabilities.general.positionEncodings = { "utf-16" }

	local on_attach = function(client)
		illuminate.on_attach(client)
		if client.name == "ruff" then
			client.server_capabilities.hoverProvider = false
		end
	end

	local server_configs = {
		harper_ls = {
			settings = {
				["harper-ls"] = {
					userDictPath = vim.fn.stdpath("config") .. "/spell/en.utf-8.add",
					diagnosticSeverity = "hint",
					linters = {
						SentenceCapitalization = true,
						LongSentences = true,
					},
				},
			},
		},
	}

	require("mason-lspconfig").setup({
		ensure_installed = langservers,
		automatic_installation = true,
		handlers = {
			function(server_name)
				local config = {
					capabilities = capabilities,
					on_attach = on_attach,
					single_file_support = true,
				}

				if server_configs[server_name] then
					config = vim.tbl_deep_extend("force", config, server_configs[server_name])
				end

				lspconfig[server_name].setup(config)
			end,
		},
	})

	vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic" })
	vim.keymap.set("n", "<leader>eq", function()
		vim.diagnostic.jump({
			count = -1,
			on_jump = function()
				vim.diagnostic.open_float()
			end,
		})
	end, { desc = "Previous diagnostic" })
	vim.keymap.set("n", "<leader>ee", function()
		vim.diagnostic.jump({
			count = 1,
			on_jump = function()
				vim.diagnostic.open_float()
			end,
		})
	end, { desc = "Next diagnostic" })

	-- https://github.com/wgsl-analyzer/wgsl-analyzer
	vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
		pattern = "*.wgsl",
		callback = function()
			vim.bo.filetype = "wgsl"
		end,
	})
end

return M
