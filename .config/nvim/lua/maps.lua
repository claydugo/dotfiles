-- make double esc clear searh highlights
-- vim.keymap.set('n', '<Esc><Esc>', '<Esc>:nohlsearch<CR><Esc>')
vim.keymap.set('n', '<Esc><Esc>', function()
    vim.api.nvim_command('nohlsearch')
    vim.fn.setreg('/', '')
end)

local function clear_search()
    vim.api.nvim_command('nohlsearch')  -- Clear the search highlighting
    vim.fn.setreg('/', '')              -- Clear the last search pattern
end

-- correct Y behavior
vim.keymap.set('n', 'Y', 'y$')

-- correct U behavior
vim.keymap.set('n', 'U', '<C-r>')

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
