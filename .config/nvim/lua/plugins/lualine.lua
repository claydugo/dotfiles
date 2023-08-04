local M = {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
}

local function get_LSP()
    local clients = vim.lsp.get_active_clients()
    local icons = require("config.langserver_icons")
    if next(clients) == nil then
        return ''
    end
    local lsp_clients = {}
    for _, client in pairs(clients) do
        local lsp_name = client.name
        if icons and icons[client.name] then
            lsp_name = icons[client.name] .. client.name
        else
            lsp_name = client.name
        end
        table.insert(lsp_clients, lsp_name)
    end
    return table.concat(lsp_clients, ' ')
end

local function search_display()
    local search = vim.fn.searchcount({maxcount = 0})
    if search.current > 0 then
        return search.current.."/"..search.total
    else
        return ""
    end
end

local padding = '  '
function M.config()
  require'lualine'.setup({
	options = {
		theme = 'auto',
		component_separators = '',
		section_separators = { left = '', right = '' },
  	},
    	sections = {
		lualine_a = {{ 'mode', separator = { left = padding .. ''}},},
		lualine_b = {'filename'},
		lualine_c = {},
		lualine_x = {search_display},
		lualine_y = {get_LSP},
		lualine_z = {
            {'diff', separator = { left = ''}},
            {'branch', separator = { right = '' .. padding}}
        },
	},
  })
end

return M
