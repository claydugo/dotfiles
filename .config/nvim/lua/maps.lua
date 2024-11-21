-- correct Y behavior
vim.keymap.set("n", "Y", "y$")

-- correct U behavior
vim.keymap.set("n", "U", "<C-r>")

-- go away
vim.keymap.set("n", "Q", "<nop>")

-- move cursor to center of screen when searching, and expand folds
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Reselect visual selection after indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- undo breakpoints
vim.keymap.set("i", ",", ",<c-g>u")
vim.keymap.set("i", ".", ".<c-g>u")
vim.keymap.set("i", ";", ";<c-g>u")

-- tactical nuke incoming
vim.keymap.set("n", "XD", ":%d<CR>", { noremap = true, silent = true })
