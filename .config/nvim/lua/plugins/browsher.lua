local home = vim.uv.os_homedir()

local plugin_dir = home .. "/projects/browsher.nvim/"
local is_local = vim.uv.fs_stat(plugin_dir) ~= nil

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
  M.url = "https://github.com/claydugo/browsher.nvim"
  M.dev = false
end

function M.config()
  require("browsher").setup(config_opts)
  vim.keymap.set("n", "<leader>b", "<cmd>Browsher<CR>", { silent = true })
  vim.keymap.set("v", "<leader>b", ":'<,'>Browsher<CR>gv", { silent = true })
  vim.keymap.set("n", "<leader>B", "<cmd>Browsher tag<CR>", { silent = true })
  vim.keymap.set("v", "<leader>B", ":'<,'>Browsher tag<CR>gv", { silent = true })
  vim.keymap.set("n", "<leader>r", "<cmd>Browsher root<CR>", { silent = true })
end

return M
