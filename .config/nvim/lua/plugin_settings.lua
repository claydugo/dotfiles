require'impatient'
local cmp = require'cmp'
cmp.setup({
  mapping = {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    -- ['<C-e>'] = cmp.mapping.close(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 's' })
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer' },
  }
})

-- install language servers
require'nvim-lsp-installer'.setup {
  automatic_installation = true
}

local capabilities = require'cmp_nvim_lsp'.update_capabilities(vim.lsp.protocol.make_client_capabilities())
local on_init = function(client)
    client.config.flags = {}
    if client.config.flags then
      client.config.flags.allow_incremental_sync = true
      client.config.flags.debounce_text_changes = 200
    end
end
local lspconfig = require'lspconfig'

lspconfig.pyright.setup{capabilities = capabilities, on_init = on_init;}
lspconfig.sumneko_lua.setup{capabilities = capabilities, on_init = on_init;}
-- npm i -g bash-language-server
lspconfig.bashls.setup{capabilities = capabilities, on_init = on_init;}

require"fidget".setup{}

--
require'nvim-web-devicons'.setup{default = true;}

require'nvim-treesitter.configs'.setup {
    ensure_installed = { "python", "lua", "bash"},
    highlight = {
        enable = true,
    }
}
--
local tele = require'telescope'
local actions = require'telescope.actions'
tele.setup{
    defaults = {
        file_ignore_patterns = {
            '%.jpg',
            '%.jpeg',
            '%.png',
            '%.mp4',
            '%.nc',
            '%.tif',
            '%.bmp',
            '%.cpython',
            '%.ui',
            '%.fig',
            '%.ttf',
            '%.pdf',
            '%.bin',
            '.git',
        },
        mappings = {
            -- insert mode mappings
            i = {
                ['<C-j>'] = actions.move_selection_next,
                ['<C-k>'] = actions.move_selection_previous,
                ['<ESC>'] = actions.close,
            },
            -- normal mode mappings
            n = {
                ['<ESC.'] = actions.close,
            }
        },
        vimgrep_arguments = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
            '--hidden',
        },
        color_devicons = false,
        shorten_path = true,
    },
    pickers = {
        find_files = {
            disable_devicons = true
        },
        live_grep = {
            disable_devicons = true
        },
    },
}
-- Load after setup to apply configuration
tele.load_extension'harpoon'
tele.load_extension'fzf'

require'gitsigns'.setup()


-- lualine
local padding = '    '

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

require'lualine'.setup {
  options = {
    theme = 'tokyonight',
    component_separators = '|',
    section_separators = { left = '', right = '' },
  },
    sections = {
    lualine_a = {{ 'mode', separator = { left = padding .. ''}},},
    lualine_b = {'filename'},
    lualine_c = {},
    lualine_x = {'location', get_LSP},
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
}

vim.g.tokyonight_style = "storm"
-- vim.g.tokyonight_colors = {comment = '#FFFFFF'}

vim.cmd([[colorscheme tokyonight]])

-- Non-lua settings
vim.g.vimwiki_global_ext = 0
vim.g.vimwiki_list = {
    {
      path = '~/vimwiki/',
      syntax = 'markdown',
      ext = '.md',
    }
  }

