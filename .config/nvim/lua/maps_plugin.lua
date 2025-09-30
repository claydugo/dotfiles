vim.keymap.set("n", "<leader>f", ":lua require'telescope.builtin'.find_files({hidden = true})<CR>")
vim.keymap.set("n", "<leader>g", ":lua require'telescope.builtin'.live_grep()<CR>")

vim.keymap.set("n", "<leader>d", ":lua require'telescope.builtin'.lsp_definitions()<CR>")
vim.keymap.set("n", "<leader>t", ":lua require'telescope.builtin'.lsp_type_definitions()<CR>")

vim.keymap.set("n", "<leader>w", ":lua require'gitsigns'.toggle_current_line_blame()<CR>")

vim.api.nvim_create_augroup("startup", { clear = true })
vim.api.nvim_create_autocmd("VimEnter", {
  group = "startup",
  pattern = "*",
  callback = function()
    local arg = vim.api.nvim_eval("argv(0)")
    if arg and (vim.fn.isdirectory(arg) ~= 0 or arg == "") then
      vim.defer_fn(function()
        local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
        if buf_ft == "netrw" then
          return
        end
        require("telescope.builtin").find_files({ hidden = true })
      end, 100)
    end
  end,
})

vim.g.vimwiki_global_ext = 0
vim.g.vimwiki_list = {
  {
    path = "~/vimwiki/",
    syntax = "markdown",
    ext = ".md",
  },
}
