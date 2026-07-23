local home = vim.uv.os_homedir()
local plugin_dir = home .. "/projects/showtime/"
local is_local = vim.uv.fs_stat(plugin_dir) ~= nil

local M = {
  specs = {
    { src = "https://github.com/claydugo/showtime.nvim" },
  },
}

function M.config()
  if is_local then
    vim.opt.rtp:prepend(plugin_dir)
    if vim.uv.fs_stat(plugin_dir .. "doc") and not vim.uv.fs_stat(plugin_dir .. "doc/tags") then
      vim.cmd.helptags(plugin_dir .. "doc")
    end
  end
  require("showtime").setup({})
end

return M
