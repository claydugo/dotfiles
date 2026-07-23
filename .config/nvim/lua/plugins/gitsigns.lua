local M = {
  specs = {
    { src = "https://github.com/lewis6991/gitsigns.nvim" },
  },
}

function M.config()
  require("gitsigns").setup({
    current_line_blame_opts = {
      delay = 500,
      ignore_whitespace = true,
    },
    current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> • <summary>",
  })

  vim.keymap.set("n", "<leader>w", function()
    require("gitsigns").toggle_current_line_blame()
  end, { desc = "Toggle git blame" })
  vim.keymap.set("n", "<leader>ss", function()
    require("gitsigns").nav_hunk("next")
  end, { desc = "Next hunk" })
  vim.keymap.set("n", "<leader>sa", function()
    require("gitsigns").nav_hunk("prev")
  end, { desc = "Previous hunk" })
end

return M
