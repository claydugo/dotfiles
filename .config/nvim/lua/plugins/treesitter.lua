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
				"html",
				"json",
			},
			highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
			indent = { enable = true },
			autotag = {
				enable = true,
			},
		})
	end,
}
