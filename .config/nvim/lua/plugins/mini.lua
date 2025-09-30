return {
  "echasnovski/mini.nvim",
  version = false,
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    -- require("mini.starter").setup({
    -- 	items = { { name = "", action = "", section = "" } },
    -- 	header = "",
    -- 	footer = "",
    -- 	silent = true,
    -- })
    require("mini.hipatterns").setup({
      highlighters = {
        hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
        todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
        clay = { pattern = "%f[%w]()Clay()%f[%W]", group = "MiniHipatternsTodo" },
        hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
      },
    })
    require("mini.comment").setup()
    require("mini.trailspace").setup()
  end,
}
