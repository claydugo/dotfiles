local home = vim.uv.os_homedir()

local plugin_dir = home .. "/projects/overshoulder/"
local is_local = vim.uv.fs_stat(plugin_dir) ~= nil

local config_opts = {
  default_keymaps = true,
}

local M = {}

function M.config()
  if is_local then
    vim.opt.rtp:prepend(plugin_dir)
    if vim.uv.fs_stat(plugin_dir .. "doc") and not vim.uv.fs_stat(plugin_dir .. "doc/tags") then
      vim.cmd.helptags(plugin_dir .. "doc")
    end
    require("overshoulder").setup(config_opts)
    vim.keymap.set("v", "<leader>s", ":OvershoulderMentionSelection<cr>", { silent = true })
  end
end

return M
