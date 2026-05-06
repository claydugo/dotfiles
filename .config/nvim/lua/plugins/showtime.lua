local home = vim.uv.os_homedir()
local plugin_dir = home .. "/projects/showtime/"
local is_local = vim.uv.fs_stat(plugin_dir) ~= nil

return {
  "claydugo/showtime.nvim",
  dev = is_local,
  dir = is_local and plugin_dir or nil,
  event = "VeryLazy",
  opts = {
    commit_length = 20,
  },
}
