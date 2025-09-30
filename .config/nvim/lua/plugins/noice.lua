return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
		"rcarriga/nvim-notify",
	},
	config = function()
		require("notify").setup({
			background_colour = "#000000",
			render = "compact",
			timeout = 3000,
			top_down = true,
		})

		require("noice").setup({
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
			},
			routes = {
				{
					filter = {
						event = "msg_show",
						any = {
							{ find = "%d+L, %d+B" },
							{ find = "; after #%d+" },
							{ find = "; before #%d+" },
							{ find = "fewer lines" },
							{ find = "more lines" },
							{ find = "line less" },
							{ find = "lines yanked" },
							{ find = "lines changed" },
							{ find = "lines deleted" },
							{ find = "less lines" },
						},
					},
					opts = { skip = true },
				},
			},
		})
	end,
}
