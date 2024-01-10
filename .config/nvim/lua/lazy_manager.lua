local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--single-branch",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
end
vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup("plugins", {
	defaults = { lazy = true },
	install = { colorscheme = { "github_dark" } },
	checker = { enabled = false },
	performance = {
		cache = {
			enabled = true,
		},
		rtp = {
            disabled_plugins = {
                "gzip",
                "health",
                "man",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "rplugin",
                "spellfile",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
		},
	},
	profiling = {
		loader = true,
		require = true,
	},
})
vim.keymap.set("n", "<leader>l", "<cmd>:Lazy<cr>")
