return {
    'github/copilot.vim',
    event = "BufReadPre",
    config = function()
        vim.g.copilot_assume_mapped = true
        vim.g.copilot_node_command = "~/.nvm/versions/node/v19.2.0/bin/node"
    end
}
