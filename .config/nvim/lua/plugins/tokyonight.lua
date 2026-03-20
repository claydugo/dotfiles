local M = {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
}

function M.config()
  -- vim.o.background = "dark"
  local tokyonight = require("tokyonight")
  tokyonight.setup({
    style = "night",
    transparent = false,
    styles = {},
  })

  tokyonight.load()
end

return M
