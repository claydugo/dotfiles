local M = {
  specs = {
    { src = "https://github.com/MeanderingProgrammer/markdown.nvim" },
  },
}

function M.config()
  require("render-markdown").setup({})
end

return M
