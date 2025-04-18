return {
	"utilyre/barbecue.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"SmiteshP/nvim-navic",
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("barbecue").setup({})
		require("nvim-web-devicons").setup({ default = true })
	end,
}
