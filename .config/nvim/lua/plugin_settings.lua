require'impatient'
local cmp = require'cmp'
cmp.setup({
  mapping = {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 's' })
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer' },
  }
})

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

-- Setup lspconfig for pyright.
require('lspconfig').pyright.setup {
    capabilities = capabilities,
}

--
require'nvim-web-devicons'.setup{default = true;}

require'nvim-treesitter.configs'.setup {
    ensure_installed = { "python", "lua", "bash", "json", "yaml"},
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
            '%.nc',
            '%.tif',
            '%.cpython',
            '%.ui',
            '%.fig',
            '%.ttf',
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
        color_devicons = false,
        shorten_path = true,
    },
    extensions = {
        frecency = {
            show_scores = true,
            show_unindexed = true,
            ignore_patterns = {"*.git/*", "*/tmp/*"},
            disable_devicons = true,
            workspaces = {
                ["dotfile"]    = "~/dotfiles/",
                ["projects"] = "~/projects/",
                ["vimwiki"]    = "~/vimwiki/"
            }
        }
    },
    pickers = {
        find_files = {
            disable_devicons = true
        },
    },
}
-- Load after setup to apply configuration
tele.load_extension('harpoon')
tele.load_extension('fzf')

local padding = '    '
--
require('lualine').setup {
  options = {
    theme = 'tokyonight',
    component_separators = '|',
    section_separators = { left = '', right = '' },
  },
    sections = {
    lualine_a = {{ 'mode', separator = { left = padding .. ''}},},
    lualine_b = {'filename'},
    lualine_c = {},
    lualine_x = {'progress', 'location'},
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
