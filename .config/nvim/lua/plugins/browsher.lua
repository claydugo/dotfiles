local home = vim.loop.os_homedir()

local plugin_dir = home .. '/projects/browsher.nvim/'
local is_local = vim.loop.fs_stat(plugin_dir) ~= nil

local config_opts = {
	commit_length = 20,
}

local M = {
	event = "VeryLazy",
}
if is_local then
    M.dir = plugin_dir
    M.dev = true
else
    M.url = 'https://github.com/claydugo/browsher.nvim'
    M.dev = false
end

function M.config()
    require('browsher').setup(config_opts)
	vim.api.nvim_set_keymap("n", "<leader>b", "<cmd>Browsher<CR>", { noremap = true, silent = true })
	vim.api.nvim_set_keymap("v", "<leader>b", ":'<,'>Browsher<CR>gv", { noremap = true, silent = true })
	vim.api.nvim_set_keymap("n", "<leader>B", "<cmd>Browsher tag<CR>", { noremap = true, silent = true })
	vim.api.nvim_set_keymap("v", "<leader>B", ":'<,'>Browsher tag<CR>gv", { noremap = true, silent = true })
	vim.api.nvim_set_keymap("n", "<leader>r", "<cmd>Browsher root<CR>", { noremap = true, silent = true })
end

return M
