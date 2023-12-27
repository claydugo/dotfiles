return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        require('gitsigns').setup({
            -- current_line_blame = true,
            current_line_blame_opts = {
                delay = 500,
                ignore_whitespace = true,
            },
            current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> • <summary>',
        })
    end
}
