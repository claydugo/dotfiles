return {
  'nvim-treesitter/nvim-treesitter',
  build = ":TSUpdate",
  event = "BufReadPost",
  dependencies = {
      'tree-sitter/tree-sitter-python'
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
	end
}


