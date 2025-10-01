local home = vim.uv.os_homedir()

local plugin_dir = home .. "/projects/tip_of_my_buffer.nvim/"
local is_local = vim.uv.fs_stat(plugin_dir) ~= nil

local config_opts = {
  -- debug = is_local,
  debug = false,
}

local M = {
  event = "VeryLazy",
}
if is_local then
  M.dir = plugin_dir
  M.dev = true
else
  M.url = "https://github.com/claydugo/tip_of_my_buffer.nvim"
  M.dev = false
end

function M.config()
  require("tip_of_my_buffer").setup(config_opts)
end

return M
