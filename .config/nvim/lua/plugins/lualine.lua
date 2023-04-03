local M = {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
}

local function get_LSP()
    local msg = ''
    -- local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
    local clients = vim.lsp.get_active_clients()
    if next(clients) == nil then
      return msg
    end
    local ft_lsp_clients = {}
    for _, client in ipairs(clients) do
      -- local filetypes = client.config.filetypes
      -- if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
      --   table.insert(ft_lsp_clients, client.name)
      -- end
       table.insert(ft_lsp_clients, client.name)
    end
    return table.concat(ft_lsp_clients, ', ')
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
		theme = 'auto',
		component_separators = '',
		section_separators = { left = '', right = '' },
  	},
    	sections = {
		lualine_a = {{ 'mode', separator = { left = padding .. ''}},},
		lualine_b = {'filename'},
		lualine_c = {},
		lualine_x = {search_display, 'diff'},
		lualine_y = {get_LSP},
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
