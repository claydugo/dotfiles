local M = {
  specs = {
    { src = "https://github.com/MunifTanjim/nui.nvim" },
    { src = "https://github.com/rcarriga/nvim-notify" },
    { src = "https://github.com/folke/noice.nvim" },
  },
}

function M.config()
  require("notify").setup({
    background_colour = "#000000",
    render = "compact",
    timeout = 3000,
    top_down = true,
    merge_duplicates = true,
  })

  require("noice").setup({
    cmdline = {
      view = "cmdline",
    },
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
    },
    presets = {
      command_palette = true,
      long_message_to_split = true,
    },
    routes = {
      {
        filter = {
          event = "msg_show",
          any = {
            { find = "%d+L, %d+B" },
            { find = "; after #%d+" },
            { find = "; before #%d+" },
            { find = "fewer lines" },
            { find = "more lines" },
            { find = "line less" },
            { find = "lines yanked" },
            { find = "lines changed" },
            { find = "lines deleted" },
            { find = "less lines" },
            { find = "search hit BOTTOM" },
            { find = "search hit TOP" },
          },
        },
        opts = { skip = true },
      },
    },
  })
end

return M
