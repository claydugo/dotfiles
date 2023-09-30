vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.grepprg = "rg --vimgrep"

vim.o.encoding = 'utf-8'
vim.o.backspace = 'indent,eol,start'

vim.o.completeopt = 'menu,menuone,noselect'

vim.o.hidden = true
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false
vim.o.clipboard = 'unnamed,unnamedplus'

vim.o.cmdheight = 0
vim.o.updatetime = 300

vim.o.ignorecase = true
vim.o.incsearch = true
vim.o.smartcase = true
vim.o.hlsearch  = true

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

-- revisit this tabbing
local indent = 4
vim.o.tabstop = indent
vim.o.softtabstop = indent
vim.o.shiftwidth = indent
vim.o.smartindent = true
vim.o.autoindent = true
vim.o.expandtab = true
vim.o.smarttab = true

vim.o.ttimeout = true
vim.o.ttimeoutlen = 5
vim.o.timeoutlen = 1000
vim.o.term = 'screen-256color'

-- Remove trailing whitespace
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*" },
  command = [[%s/\s\+$//e]],
})
