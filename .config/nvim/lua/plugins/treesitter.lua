return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"python",
				"c",
				"lua",
				"bash",
				"markdown",
				"html",
				"json",
			},
			highlight = { enable = true },
			indent = { enable = true },
		})
	end,
}
