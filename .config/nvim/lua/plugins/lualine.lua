local M = {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
}

local function get_LSP()
	local clients = vim.lsp.get_active_clients()
	local icons = require("langserver_icons")
	if next(clients) == nil then
		return ""
	end
	local lsp_clients = {}
	for _, client in pairs(clients) do
		local lsp_name = client.name
		if icons and icons[client.name] then
			lsp_name = icons[client.name]
		else
			lsp_name = client.name
		end
		table.insert(lsp_clients, lsp_name)
	end
	return table.concat(lsp_clients, " ")
end

local function search_display()
	local search = vim.fn.searchcount({ maxcount = 0 })
	local search_term = vim.fn.getreg("/")
	if search.current > 0 then
		return "/" .. search_term .. " [" .. search.current .. "/" .. search.total .. "]"
	else
		return ""
	end
end

function M.config()
	require("lualine").setup({
		options = {
			theme = "nord",
			component_separators = "",
			section_separators = { left = "", right = "" },
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = {
				{
					"filename",
					path = 3,
				},
			},
			lualine_c = {},
			lualine_x = { search_display },
			lualine_y = {
				{ "diff" },
				{ "branch" },
			},
			lualine_z = { get_LSP },
		},
	})
end

return M
