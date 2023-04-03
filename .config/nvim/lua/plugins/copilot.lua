return {
    "zbirenbaum/copilot.lua",
    event = "bufreadpre",
    cmd = { "Copilot" },
    dependencies = {
        { "zbirenbaum/copilot-cmp" },
    },
    config = function()
        require('copilot').setup({
            suggestion = {
                auto_trigger = true,
                keymap = {
                    accept = "<Tab>",
                    next = "<C-l>",
                    prev = "<C-h>",
                    dismiss = "<C-d>",
                },
            },
            copilot_node_command = "node",
            server_opts_overrides = {}
        })
    end
}
