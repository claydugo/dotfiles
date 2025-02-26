local M = {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
}

local function get_LSP()
  local clients = vim.lsp.get_clients()
  if not next(clients) then return "" end
  local icons = require("langserver_icons")
  local lsp_names = {}
  for _, client in pairs(clients) do
    table.insert(lsp_names, icons and icons[client.name] or client.name)
  end
  return table.concat(lsp_names, " ")
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
			theme = "auto",
			component_separators = "",
			section_separators = { left = "", right = "" },
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = { "filename" },
			lualine_c = {},
			lualine_x = { search_display },
			lualine_y = { get_LSP },
			lualine_z = {
				{ "branch" },
				{ "diff" },
			},
		},
	})
end

return M
