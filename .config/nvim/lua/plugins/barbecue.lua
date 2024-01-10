return {
    "utilyre/barbecue.nvim",
	event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "SmiteshP/nvim-navic",
    },
    config = function()
        require("barbecue").setup({
    })
    end,
}
