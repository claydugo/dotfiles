return {
	"saghen/blink.cmp",
	lazy = false,
	build = "cargo +nightly build --release",
	dependencies = { "rafamadriz/friendly-snippets" },
	opts = {
		keymap = {
			preset = "default",
			["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
			["<C-e>"] = { "hide", "fallback" },
			["<CR>"] = { "accept", "fallback" },
			["<Tab>"] = {
				function(cmp)
					if vim.fn.exists("*copilot#Accept") == 1 then
						local suggestion = vim.fn["copilot#GetDisplayedSuggestion"]()
						if suggestion and suggestion.text and suggestion.text ~= "" then
							local accept_keys = vim.fn["copilot#Accept"]("")
							if accept_keys and accept_keys ~= "" then
								vim.api.nvim_feedkeys(accept_keys, "n", true)
								-- Go to next line with proper indentation
								vim.schedule(function()
									local esc = vim.api.nvim_replace_termcodes("<Esc>o", true, false, true)
									vim.api.nvim_feedkeys(esc, "n", false)
								end)
								return true
							end
						end
					end
					if cmp.is_visible() then
						return cmp.accept()
					end
					return false
				end,
				"fallback",
			},
			["<S-Tab>"] = { "select_prev", "fallback" },
			["<C-j>"] = { "select_next", "fallback" },
			["<C-k>"] = { "select_prev", "fallback" },
			["<Up>"] = { "select_prev", "fallback" },
			["<Down>"] = { "select_next", "fallback" },
			["<C-d>"] = { "scroll_documentation_up", "fallback" },
			["<C-f>"] = { "scroll_documentation_down", "fallback" },
		},
		appearance = {
			use_nvim_cmp_as_default = true,
			nerd_font_variant = "mono",
		},
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
		},
		completion = {
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 300,
			},
			menu = {
				draw = {
					treesitter = { "lsp" },
				},
			},
		},
		signature = {
			enabled = true,
		},
		fuzzy = {
			implementation = "prefer_rust",
		},
	},
}
