if vim.fn.executable("javac") == 0 then
  return
end

vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.expandtab = false

local opts = { buffer = true, noremap = true, silent = true }
vim.keymap.set("n", "<leader>b", ":!./gradlew build<CR>", vim.tbl_extend("force", opts, { desc = "Gradle build" }))
vim.keymap.set("n", "<leader>tt", ":!./gradlew test<CR>", vim.tbl_extend("force", opts, { desc = "Gradle test" }))
vim.keymap.set(
  "n",
  "<leader>tl",
  ":!./gradlew tasks<CR>",
  vim.tbl_extend("force", opts, { desc = "List gradle tasks" })
)
