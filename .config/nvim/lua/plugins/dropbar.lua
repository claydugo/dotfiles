local M = {
  specs = {
    { src = "https://github.com/nvim-tree/nvim-web-devicons" },
    { src = "https://github.com/claydugo/dropbar.nvim", version = "fix/buf-modified-set-removal" },
  },
}

function M.config()
  require("nvim-web-devicons").setup({ default = true })

  local dropbar_api = require("dropbar.api")
  vim.keymap.set("n", "<Leader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
end

return M
