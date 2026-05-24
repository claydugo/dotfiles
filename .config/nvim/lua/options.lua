vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.grepprg = "rg --vimgrep"
vim.o.grepformat = "%f:%l:%c:%m"

vim.o.encoding = "utf-8"
vim.o.backspace = "indent,eol,start"

vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.completeopt:append("fuzzy")
vim.opt.completeopt:append("nearest")

vim.o.hidden = true
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false
vim.o.undofile = true
vim.o.confirm = true
vim.opt.clipboard = { "unnamed", "unnamedplus" }
vim.opt.jumpoptions = "stack,view"

vim.o.updatetime = 300
vim.o.ignorecase = true
vim.o.incsearch = true
vim.o.smartcase = true
vim.o.hlsearch = true
vim.opt.shortmess:append("S")
vim.opt.shortmess:append("WIcC")

vim.o.history = 1000
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

vim.o.winborder = "rounded"
vim.o.pumheight = 5
vim.o.pumblend = 20

vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

-- Windows: native builds (tree-sitter parsers, telescope-fzf-native) need a C
-- compiler. With no MSVC (cl.exe), point $CC at zig via a small wrapper so they
-- build from the pixi-provided zig instead of failing on a missing cl.exe.
if vim.fn.has("win32") == 1 and vim.fn.executable("cl") == 0 and vim.fn.executable("zig") == 1 then
  vim.env.CC = vim.fs.joinpath(vim.fn.stdpath("config"), "bin", "zig-cc.cmd")
end

-- Remove trailing whitespace
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*" },
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

-- Strip leading whitespace for commit messages
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  callback = function()
    if vim.bo.filetype == "jj" or vim.bo.filetype == "gitcommit" then
      local save_cursor = vim.fn.getpos(".")
      vim.cmd([[keeppatterns %s/^\s\+//e]])
      vim.fn.setpos(".", save_cursor)
    end
  end,
})

if vim.g.vscode then
  vim.o.cmdheight = 3
else
  vim.o.cmdheight = 0
end

vim.cmd([[
	command! Q q
	command! Qa qa
	command! QA qa
	command! W w
	command! Wq wq
	command! WQ wq
]])
