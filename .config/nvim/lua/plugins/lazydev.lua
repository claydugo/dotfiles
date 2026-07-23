local M = {
  specs = {
    { src = "https://github.com/Bilal2453/luvit-meta" },
    { src = "https://github.com/folke/lazydev.nvim" },
  },
}

function M.config()
  require("lazydev").setup({
    library = {
      {
        path = vim.fn.stdpath("data") .. "/site/pack/core/opt/luvit-meta/library",
        words = { "vim%.uv" },
      },
    },
  })
end

return M
