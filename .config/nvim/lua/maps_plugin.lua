vim.keymap.set("n", "<leader>f", ":lua require'telescope.builtin'.find_files({hidden = true})<CR>")
vim.keymap.set("n", "<leader>g", ":lua require'telescope.builtin'.live_grep()<CR>")

vim.keymap.set("n", "<leader>d", ":lua require'telescope.builtin'.lsp_definitions()<CR>")
vim.keymap.set("n", "<leader>t", ":lua require'telescope.builtin'.lsp_type_definitions()<CR>")

vim.keymap.set("n", "<leader>hh", ":lua require'harpoon.ui'.toggle_quick_menu()<CR>")
vim.keymap.set("n", "<leader>ha", ":lua require'harpoon.mark'.add_file()<CR>")
vim.keymap.set("n", "<leader>1", ":lua require'harpoon.ui'.nav_file(1)<CR>")
vim.keymap.set("n", "<leader>2", ":lua require'harpoon.ui'.nav_file(2)<CR>")
vim.keymap.set("n", "<leader>3", ":lua require'harpoon.ui'.nav_file(3)<CR>")
vim.keymap.set("n", "<leader>4", ":lua require'harpoon.ui'.nav_file(4)<CR>")
vim.keymap.set("n", "<leader>5", ":lua require'harpoon.ui'.nav_file(5)<CR>")
vim.keymap.set("n", "<leader>6", ":lua require'harpoon.ui'.nav_file(6)<CR>")
vim.keymap.set("n", "<leader>7", ":lua require'harpoon.ui'.nav_file(7)<CR>")
vim.keymap.set("n", "<leader>8", ":lua require'harpoon.ui'.nav_file(8)<CR>")
vim.keymap.set("n", "<leader>9", ":lua require'harpoon.ui'.nav_file(9)<CR>")
-- idk at sompoint this is required
-- local harpoon = require("harpoon")
-- vim.keymap.set("n", "<leader>ha", function() harpoon:list():append() end)
-- vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
--
-- vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end)
-- vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end)
-- vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end)
-- vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end)
-- vim.keymap.set("n", "<leader>5", function() harpoon:list():select(5) end)
-- vim.keymap.set("n", "<leader>6", function() harpoon:list():select(6) end)
-- vim.keymap.set("n", "<leader>7", function() harpoon:list():select(7) end)
-- vim.keymap.set("n", "<leader>8", function() harpoon:list():select(8) end)
-- vim.keymap.set("n", "<leader>9", function() harpoon:list():select(9) end)

vim.keymap.set("n", "<leader>gb", ":lua require'gitsigns'.toggle_current_line_blame()<CR>")

vim.api.nvim_create_augroup("startup", { clear = true })
vim.api.nvim_create_autocmd("VimEnter", {
	group = "startup",
	pattern = "*",
	callback = function()
		local arg = vim.api.nvim_eval("argv(0)")
		if arg and (vim.fn.isdirectory(arg) ~= 0 or arg == "") then
			vim.defer_fn(function()
				require("telescope.builtin").find_files({ hidden = true })
			end, 10)
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
-- barbecue optimization recommended as of 20230110
require("barbecue").setup({
  create_autocmd = false,
})
vim.api.nvim_create_autocmd({
  "WinResized", -- or WinResized on NVIM-v0.9 and higher
  "BufWinEnter",
  "CursorHold",
  "InsertLeave",
}, {
  group = vim.api.nvim_create_augroup("barbecue.updater", {}),
  callback = function()
    require("barbecue.ui").update()
  end,
})
