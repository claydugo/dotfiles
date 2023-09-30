return {
  'nvim-treesitter/nvim-treesitter',
  build = ":TSUpdate",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
      'tree-sitter/tree-sitter-python',
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
		  highlight = { enable = true, },
	})
    require("treesitter-context").setup({
      -- they bumped this at some point and now its annoying
      -- will have to play around to find a good sweet spot
      multiline_threshold = 4,
    })
	end
}


