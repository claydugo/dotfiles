return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  keys = {
    {
      "<leader>w",
      function()
        require("gitsigns").toggle_current_line_blame()
      end,
      desc = "Toggle git blame",
    },
    {
      "<leader>ss",
      function()
        require("gitsigns").next_hunk()
      end,
      desc = "Next hunk",
    },
    {
      "<leader>sa",
      function()
        require("gitsigns").prev_hunk()
      end,
      desc = "Previous hunk",
    },
  },
  config = function()
    require("gitsigns").setup({
      current_line_blame_opts = {
        delay = 500,
        ignore_whitespace = true,
      },
      current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> • <summary>",
    })
  end,
}
