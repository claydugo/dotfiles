vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.grepprg = "rg --vimgrep"
vim.o.grepformat = "%f:%l:%c:%m"

vim.o.encoding = "utf-8"
vim.o.backspace = "indent,eol,start"

vim.o.completeopt = "menu,menuone,noselect"

vim.o.hidden = true
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false
vim.o.clipboard = "unnamed,unnamedplus"

vim.o.updatetime = 200
vim.o.ignorecase = true
vim.o.incsearch = true
vim.o.smartcase = true
vim.o.hlsearch = true

vim.o.history = 50
vim.o.ruler = true
vim.o.showcmd = true
vim.o.autowrite = true
vim.o.modelines = 0
vim.o.modeline = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.showmode = false
vim.o.scrolloff = 6

vim.o.visualbell = true
vim.o.showmatch = true

vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.smartindent = true
vim.o.autoindent = true
vim.o.expandtab = true
vim.o.smarttab = true

vim.o.ttimeout = true
vim.o.ttimeoutlen = 5
vim.o.timeoutlen = 1000

vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

-- local cache_file = vim.fn.stdpath("cache") .. "/python3_host_prog"
-- local function get_conda_python_path()
-- 	if vim.fn.filereadable(cache_file) == 1 then
-- 		return vim.fn.readfile(cache_file)[1]
-- 	end
-- 	if vim.fn.executable("conda") == 1 then
-- 		local handle = io.popen("conda run which python")
-- 		local result = handle:read("*a"):gsub("\n", "")
-- 		handle:close()
-- 		vim.fn.writefile({ result }, cache_file)
-- 		return result
-- 	end
-- 	return nil
-- end
--
-- local python3_host_prog = get_conda_python_path()
-- if python3_host_prog then
-- 	vim.g.python3_host_prog = python3_host_prog
-- end

-- Remove trailing whitespace
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	pattern = { "*" },
	command = [[%s/\s\+$//e]],
})

if vim.g.vscode then
	vim.o.cmdheight = 3
else
	vim.o.cmdheight = 0
	local function adjust_cmdheight()
		vim.o.cmdheight = 1
		vim.defer_fn(function()
			vim.o.cmdheight = 0
		end, 3000)
	end

	local original_notify = vim.notify
	vim.notify = function(msg, ...)
		adjust_cmdheight()
		original_notify(msg, ...)
	end
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "lua",
	callback = function()
		vim.bo.expandtab = false
	end,
})
