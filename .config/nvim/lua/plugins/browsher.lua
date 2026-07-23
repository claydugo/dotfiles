local home = vim.uv.os_homedir()

local plugin_dir = home .. "/projects/browsher.nvim/"
local is_local = vim.uv.fs_stat(plugin_dir) ~= nil

local config_opts = {
  commit_length = 20,
}

local M = {
  specs = {
    { src = "https://github.com/claydugo/browsher.nvim" },
  },
}

function M.config()
  if is_local then
    vim.opt.rtp:prepend(plugin_dir)
    if vim.uv.fs_stat(plugin_dir .. "doc") and not vim.uv.fs_stat(plugin_dir .. "doc/tags") then
      vim.cmd.helptags(plugin_dir .. "doc")
    end
  end
  require("browsher").setup(config_opts)
  vim.keymap.set("n", "<leader>b", "<cmd>Browsher<CR>", { silent = true })
  vim.keymap.set("v", "<leader>b", ":'<,'>Browsher<CR>gv", { silent = true })
  vim.keymap.set("n", "<leader>B", "<cmd>Browsher tag<CR>", { silent = true })
  vim.keymap.set("v", "<leader>B", ":'<,'>Browsher tag<CR>gv", { silent = true })
  vim.keymap.set("n", "<leader>r", "<cmd>Browsher root<CR>", { silent = true })
end

return M
