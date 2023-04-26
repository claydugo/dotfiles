local M = {
    "nvim-telescope/telescope.nvim",
    cmd = { "Telescope" },

    dependencies = {
        { "nvim-lua/plenary.nvim" },
        -- { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        { "ThePrimeagen/harpoon" },
    },
}

function M.config()
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
                '%.ipynb',
                '%.ui',
                '%.fig',
                '%.ttf',
                '%.pdf',
                '%.bin',
                '.git/',
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
            borderchars = { " ", " ", " ", " ", " ", " ", " ", " " },
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
-- tele.load_extension'fzf'
end

return M
