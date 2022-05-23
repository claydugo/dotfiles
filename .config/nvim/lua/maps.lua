local map = vim.api.nvim_set_keymap

-- make double esc clear searh highlights
map('n', '<Esc><Esc>', '<Esc>:nohlsearch<CR><Esc>', {noremap = true, silent = true})

options = {noremap = true }

-- correct Y behavior
map('n', 'Y', 'y$', options)

-- undo breakpoints
map('i', ',', ',<c-g>u', options)
map('i', '.', '.<c-g>u', options)
map('i', '!', '!<c-g>u', options)
map('i', '?', '?<c-g>u', options)

-- debugging strings
map('i', '<leader>pp', 'print(', options)
map('i', '<leader>hh', 'print(\'hit\')', options)
map('i', '<leader>pf', 'print(f\'var: {var}\')', options)
map('i', '<leader>88', 'print(\'*\'*75)', options)
-- vimwiki title insert
map('i', '<leader>==', '===== Title =====', options)

-- Find files using telescope command-line
-- hidden flag allows you to see dotfiles
map('n', '<leader>ff', ':lua require\'telescope.builtin\'.find_files({hidden = true})<cr>', options)
-- grep directory with ripgrep
map('n', '<leader>fg', ':lua require\'telescope.builtin\'.live_grep()<cr>', options)
-- frecency algo, most commonly accessed files - not dir specific
map('n', '<leader>fc', ':lua require\'telescope\'.extensions.frecency.frecency()<cr>', options)
map('n', '<leader>fb', ':lua require\'telescope.builtin\'.buffers()<cr>', options)
map('n', '<leader>fh', ':lua require\'telescope.builtin\'.help_tags()<cr>', options)
-- goto definition of var/func under cursor
map('n', '<leader>fd', ':lua require\'telescope.builtin\'.lsp_definitions()<cr>', options)
-- goto type definition of var under cursor
map('n', '<leader>ft', ':lua require\'telescope.builtin\'.lsp_type_definitions()<cr>', options)

-- Harpoon
map('n', '<C-e>', ':lua require\'harpoon.ui\'.toggle_quick_menu()<CR>', options)
map('n', '<C-a>', ':lua require\'harpoon.mark\'.add_file()<CR>', options)
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
