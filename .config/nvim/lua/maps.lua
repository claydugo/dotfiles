local map = vim.api.nvim_set_keymap

-- make double esc clear searh highlights
map('n', '<Esc><Esc>', '<Esc>:nohlsearch<CR><Esc>', {noremap = true, silent = true})

local options = {noremap = true }

-- correct Y behavior
map('n', 'Y', 'y$', options)

-- correct U behavior
map('n', 'U', '<C-r>', options)

-- undo breakpoints
map('i', ',', ',<c-g>u', options)
map('i', '.', '.<c-g>u', options)
map('i', '!', '!<c-g>u', options)
map('i', '?', '?<c-g>u', options)

-- Find files using telescope command-line
-- hidden flag allows you to see dotfiles
map('n', '<leader>ff', ':lua require\'telescope.builtin\'.find_files({hidden = true})<CR>', options)
map('n', '<leader>fa', ':lua require\'telescope.builtin\'.find_files()<CR>', options)
-- grep directory with ripgrep
map('n', '<leader>fg', ':lua require\'telescope.builtin\'.live_grep()<CR>', options)
map('n', '<leader>fb', ':lua require\'telescope.builtin\'.buffers()<CR>', options)
map('n', '<leader>fh', ':lua require\'telescope.builtin\'.help_tags()<CR>', options)
-- goto definition of var/func under cursor
map('n', '<leader>fd', ':lua require\'telescope.builtin\'.lsp_definitions()<CR>', options)
-- goto type definition of var under cursor
map('n', '<leader>ft', ':lua require\'telescope.builtin\'.lsp_type_definitions()<CR>', options)
-- list all telescope menus
map('n', '<leader>bb', ':lua require\'telescope.builtin\'.builtin()<CR>', options)

-- Harpoon
map('n', '<leader>hh', ':lua require\'harpoon.ui\'.toggle_quick_menu()<CR>', options)
map('n', '<leader>ha', ':lua require\'harpoon.mark\'.add_file()<CR>', options)
map('n', '<leader>qq', ':lua require\'harpoon.ui\'.nav_prev()<CR>', options)
map('n', '<leader>ee', ':lua require\'harpoon.ui\'.nav_next()<CR>', options)
map('n', '<leader>1', ':lua require\'harpoon.ui\'.nav_file(1)<CR>', options)
map('n', '<leader>2', ':lua require\'harpoon.ui\'.nav_file(2)<CR>', options)
map('n', '<leader>3', ':lua require\'harpoon.ui\'.nav_file(3)<CR>', options)
map('n', '<leader>4', ':lua require\'harpoon.ui\'.nav_file(4)<CR>', options)
map('n', '<leader>5', ':lua require\'harpoon.ui\'.nav_file(5)<CR>', options)
map('n', '<leader>6', ':lua require\'harpoon.ui\'.nav_file(6)<CR>', options)
map('n', '<leader>7', ':lua require\'harpoon.ui\'.nav_file(7)<CR>', options)
map('n', '<leader>8', ':lua require\'harpoon.ui\'.nav_file(8)<CR>', options)
map('n', '<leader>9', ':lua require\'harpoon.ui\'.nav_file(9)<CR>', options)

-- Gitsigns
map('n', '<leader>gb', ':lua require\'gitsigns\'.toggle_current_line_blame()<CR>', options)
map('n', '<leader>gd', ':lua require\'gitsigns\'.diffthis()<CR>', options)

-- nvim tree
map('n', '<leader>tt', ':NvimTreeToggle<CR>', options)
map('n', '<leader>tf', ':NvimTreeFocus<CR>', options)

-- fun
map("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>", options)
map("n", "<leader>mg", "<cmd>CellularAutomaton game_of_life<CR>", options)
