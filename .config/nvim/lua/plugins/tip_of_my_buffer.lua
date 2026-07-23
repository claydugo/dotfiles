local home = vim.uv.os_homedir()

local plugin_dir = home .. "/projects/tip_of_my_buffer.nvim/"
local is_local = vim.uv.fs_stat(plugin_dir) ~= nil

local config_opts = {
  -- debug = is_local,
  debug = false,
}

local M = {
  specs = {
    { src = "https://github.com/claydugo/tip_of_my_buffer.nvim" },
  },
}

function M.config()
  if is_local then
    vim.opt.rtp:prepend(plugin_dir)
    if vim.uv.fs_stat(plugin_dir .. "doc") and not vim.uv.fs_stat(plugin_dir .. "doc/tags") then
      vim.cmd.helptags(plugin_dir .. "doc")
    end
  end
  require("tip_of_my_buffer").setup(config_opts)
end

return M
