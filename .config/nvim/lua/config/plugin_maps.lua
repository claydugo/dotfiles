-- Find files using telescope command-line
-- hidden flag allows you to see dotfiles
vim.keymap.set('n', '<leader>ff', ':lua require\'telescope.builtin\'.find_files({hidden = true})<CR>')
vim.keymap.set('n', '<leader>fa', ':lua require\'telescope.builtin\'.find_files()<CR>')
vim.keymap.set('n', '<leader>fu', ':lua require\'telescope\'.extensions.undo.undo()<CR>')
-- grep directory with ripgrep
vim.keymap.set('n', '<leader>fg', ':lua require\'telescope.builtin\'.live_grep()<CR>')
vim.keymap.set('n', '<leader>fb', ':lua require\'telescope.builtin\'.buffers()<CR>')
vim.keymap.set('n', '<leader>fh', ':lua require\'telescope.builtin\'.help_tags()<CR>')
-- goto definition of var/func under cursor
vim.keymap.set('n', '<leader>fd', ':lua require\'telescope.builtin\'.lsp_definitions()<CR>')
-- goto type definition of var under cursor
vim.keymap.set('n', '<leader>ft', ':lua require\'telescope.builtin\'.lsp_type_definitions()<CR>')
-- list all telescope menus
vim.keymap.set('n', '<leader>bb', ':lua require\'telescope.builtin\'.builtin()<CR>')

-- Harpoon
vim.keymap.set('n', '<leader>hh', ':lua require\'harpoon.ui\'.toggle_quick_menu()<CR>')
vim.keymap.set('n', '<leader>ha', ':lua require\'harpoon.mark\'.add_file()<CR>')
vim.keymap.set('n', '<leader>qq', ':lua require\'harpoon.ui\'.nav_prev()<CR>')
vim.keymap.set('n', '<leader>ee', ':lua require\'harpoon.ui\'.nav_next()<CR>')
vim.keymap.set('n', '<leader>1', ':lua require\'harpoon.ui\'.nav_file(1)<CR>')
vim.keymap.set('n', '<leader>2', ':lua require\'harpoon.ui\'.nav_file(2)<CR>')
vim.keymap.set('n', '<leader>3', ':lua require\'harpoon.ui\'.nav_file(3)<CR>')
vim.keymap.set('n', '<leader>4', ':lua require\'harpoon.ui\'.nav_file(4)<CR>')
vim.keymap.set('n', '<leader>5', ':lua require\'harpoon.ui\'.nav_file(5)<CR>')
vim.keymap.set('n', '<leader>6', ':lua require\'harpoon.ui\'.nav_file(6)<CR>')
vim.keymap.set('n', '<leader>7', ':lua require\'harpoon.ui\'.nav_file(7)<CR>')
vim.keymap.set('n', '<leader>8', ':lua require\'harpoon.ui\'.nav_file(8)<CR>')
vim.keymap.set('n', '<leader>9', ':lua require\'harpoon.ui\'.nav_file(9)<CR>')

-- Gitsigns
vim.keymap.set('n', '<leader>gb', ':lua require\'gitsigns\'.toggle_current_line_blame()<CR>')
vim.keymap.set('n', '<leader>b', ':lua require\'gitsigns\'.blame_line()<CR>')
vim.keymap.set('n', '<leader>gd', ':lua require\'gitsigns\'.diffthis()<CR>')

vim.api.nvim_create_augroup('startup', { clear = true })
vim.api.nvim_create_autocmd('VimEnter', {
    group = 'startup',
    pattern = '*',
    callback = function()
      -- Open file browser if argument is a folder
      local arg = vim.api.nvim_eval('argv(0)')
      if arg and (vim.fn.isdirectory(arg) ~= 0 or arg == "") then
        vim.defer_fn(function()
          require'telescope.builtin'.find_files({hidden = true})
        end, 10)
      end
    end
})

vim.g.vimwiki_global_ext = 0
vim.g.vimwiki_list = {
    {
      path = '~/vimwiki/',
      syntax = 'markdown',
      ext = '.md',
    }
}