return {
    "zbirenbaum/copilot.lua",
    event = "bufreadpre",
    cmd = { "Copilot" },
    config = function()
        require('copilot').setup({
            panel = { enabled = false },
            suggestion = {
                enabled = true,
                auto_trigger = true,
                keymap = {
                    next = "<C-l>",
                    prev = "<C-h>",
                    dismiss = "<C-d>",
                },
            },
            -- copilot_node_command = "node",
            server_opts_overrides = {}
        })
    end
}
