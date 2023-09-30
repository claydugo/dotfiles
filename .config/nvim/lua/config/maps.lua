--
-- make double esc clear searh highlights
vim.keymap.set('n', '<Esc><Esc>', '<Esc>:nohlsearch<CR><Esc>')

-- correct Y behavior
vim.keymap.set('n', 'Y', 'y$')

-- correct U behavior
vim.keymap.set('n', 'U', '<C-r>')

-- move u/d - not working, highlight ending on confirm
-- vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
-- vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- go away
vim.keymap.set('n', 'Q', '<nop>')

-- move cursor to center of screen when searching, and expand folds
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Reselect visual selection after indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- undo breakpoints
vim.keymap.set('i', ',', ',<c-g>u')
vim.keymap.set('i', '.', '.<c-g>u')
vim.keymap.set('i', ';', ';<c-g>u')
