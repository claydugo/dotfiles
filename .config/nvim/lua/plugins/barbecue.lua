return {
	"utilyre/barbecue.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"SmiteshP/nvim-navic",
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("barbecue").setup({
			create_autocmd = false,
		})
		require("nvim-web-devicons").setup({ default = true })

		local group = vim.api.nvim_create_augroup("barbecue.updater", {})
		vim.api.nvim_create_autocmd({
			"WinResized",
			"BufWinEnter",
			"CursorHold",
			"InsertLeave",
		}, {
			group = group,
			callback = function()
				require("barbecue.ui").update()
			end,
		})
	end,
}
