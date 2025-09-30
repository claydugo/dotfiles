return {
	"Bekaboo/dropbar.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("nvim-web-devicons").setup({ default = true })

		local dropbar_api = require("dropbar.api")
		vim.keymap.set("n", "<Leader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
	end,
}
