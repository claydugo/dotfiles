return {
  "github/copilot.vim",
  lazy = false,
  init = function()
    -- Disable default Tab mapping, setup in blink-cmp
    vim.g.copilot_no_tab_map = true
    if vim.fn.has("win32") == 1 then
      vim.g.copilot_version = false
    end
  end,
}
