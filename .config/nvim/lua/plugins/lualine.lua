local M = {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
}

-- from https://github.com/nvim-lualine/lualine.nvim/blob/master/examples/evil_lualine.lua
local function get_LSP()
    local msg = ''
    local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
    local clients = vim.lsp.get_active_clients()
    if next(clients) == nil then
      return msg
    end
    for _, client in ipairs(clients) do
      local filetypes = client.config.filetypes
      if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
        return client.name
      end
    end
    return msg
end

local function search_display()
    local search = vim.fn.searchcount({maxcount = 0})
    if search.current > 0 then
        return search.current.."/"..search.total
    else
        return ""
    end
end

local padding = '    '
function M.config()
  require'lualine'.setup({
	options = {
		theme = 'tokyonight',
		component_separators = '',
		section_separators = { left = '', right = '' },
  	},
    	sections = {
		lualine_a = {{ 'mode', separator = { left = padding .. ''}},},
		lualine_b = {'filename'},
		lualine_c = {},
		lualine_x = {search_display, get_LSP},
		lualine_y = {'diff'},
		lualine_z = {{'branch', separator = { right = '' .. padding}},},
	},
  	inactive_sections = {
    		lualine_a = {'filename'},
    		lualine_b = {},
		lualine_c = {},
    		lualine_x = {},
    		lualine_y = {},
    		lualine_z = {'branch'},
  	},
  	tabline = {},
  	extensions = {}
  })
end

return M
