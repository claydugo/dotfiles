return {
	"supermaven-inc/supermaven-nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("supermaven-nvim").setup({})
	end,
}
