return {
  'nvim-treesitter/nvim-treesitter',
  build = ":TSUpdate",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
      'nvim-treesitter/nvim-treesitter-context',
  },
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
    require("treesitter-context").setup({
      -- they bumped this at some point to some worse default
      multiline_threshold = 4,
    })
	end
}
