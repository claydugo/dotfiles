return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	config = function()
		require("nvim-ts-autotag").setup()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"python",
				"lua",
				"wgsl",
				"cuda",
				"rust",
				"c",
				"bash",

				"html",
				"json",
				"qmldir",
				"luadoc",

				"desktop",
				"tmux",
				"ssh_config",
				"git_config",
				"git_rebase",
				"gitattributes",
				"gitcommit",
				"gitignore",
			},
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			indent = { enable = true },
		})
	end,
}
