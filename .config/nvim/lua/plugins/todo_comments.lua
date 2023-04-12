return {
    "folke/todo-comments.nvim",
    event = "BufReadPre",
    config = function()
        require("todo-comments").setup {
            keywords = {
                HACK = { icon = " ", color = "warning", alt = {"HACKHACKHACK"} },
                CLAY = { icon = " ", color = "clay", alt = {"Clay", "clay"} },
            },
            colors = {
                clay = { "Identifier", "#FF3396" },
            },
        }
    end
}
