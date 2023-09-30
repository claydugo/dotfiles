local M = {
    "nvim-telescope/telescope.nvim",
    -- dir = "~/projects/telescope.nvim/",
    lazy = false,
    cmd = { "Telescope" },
    dependencies = {
        { "nvim-lua/plenary.nvim" },
        -- { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        { "natecraddock/telescope-zf-native.nvim" },
        { "ThePrimeagen/harpoon" },
        { "debugloop/telescope-undo.nvim" },
    },
}

function M.config()
    local tele = require'telescope'
    local actions = require'telescope.actions'
    tele.setup{
        defaults = {
            -- https://github.com/nvim-telescope/telescope.nvim/issues/2667#issuecomment-1700970850
            sorting_strategy = "ascending",
            layout_config = {
                horizontal = {
                    prompt_position = "top",
                },
                vertical = {
                    prompt_position = "top",
                }
            },
            prompt_prefix = "🔬 ",
            -- selection_caret = " ",
            file_ignore_patterns = {
                '%.jpg',
                '%.jpeg',
                '%.png',
                '%.mp4',
                '%.nc',
                '%.tif',
                '%.bmp',
                '%.cpython',
                '%.npy',
                '%.ipynb',
                '%.ui',
                '%.fig',
                '%.xls',
                '%.ttf',
                '%.pdf',
                '%.bin',
                '.git/',
            },
            mappings = {
                -- insert mode mappings
                i = {
                    ["<RightMouse>"] = actions.close,
                    ["<LeftMouse>"] = actions.select_default,
                    ["<ScrollWheelDown>"] = actions.move_selection_next,
                    ["<ScrollWheelUp>"] = actions.move_selection_previous,
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
            -- borderchars = { " ", " ", " ", " ", " ", " ", " ", " " },
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
tele.load_extension'zf-native'
-- tele.load_extension'fzf'
tele.load_extension'undo'
end

return M
