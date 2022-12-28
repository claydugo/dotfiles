vim.g.mapleader = ','

local opt = vim.o
opt.encoding = 'utf-8'
opt.backspace = 'indent,eol,start'

opt.completeopt = 'menu,menuone,noselect'

opt.hidden = true
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.clipboard = 'unnamed,unnamedplus'

-- back to trying cmdheight 0 now that
-- neovim 9.0 on the ppa
opt.cmdheight = 0
opt.updatetime = 300

opt.ignorecase = true
opt.incsearch = true
opt.smartcase = true
opt.hlsearch  = true

opt.history = 50
opt.ruler = true
opt.showcmd = true
opt.autowrite = true
opt.modelines = 0
opt.modeline = true
opt.number = true
opt.relativenumber = true
opt.showmode = false

opt.visualbell = true
opt.showmatch = true

-- revisit this tabbing
local indent = 4
opt.tabstop = indent
opt.softtabstop = indent
opt.shiftwidth = indent
opt.smartindent = true
opt.autoindent = true
opt.expandtab = true
opt.smarttab = true

opt.ttimeout = true
opt.ttimeoutlen = 5
opt.timeoutlen = 1000
opt.term = 'screen-256color'

-- disable unused built in plugins
local disabled_built_ins = {
    "netrw",
    "netrwPlugin",
    "netrwSettings",
    "netrwFileHandlers",
    "gzip",
    "zip",
    "zipPlugin",
    "tar",
    "tarPlugin",
    "getscript",
    "getscriptPlugin",
    "vimball",
    "vimballPlugin",
    "tohtml_plugin",
    "logipat",
    "rrhelper",
    "spellfile_plugin",
    "matchit",
    "matchparen",
}

for _, plugin in pairs(disabled_built_ins) do
    vim.g["loaded_" .. plugin] = 1
end

-- shut the fuck up
vim.g.copilot_assume_mapped = true

-- Remove trailing whitespace
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*" },
  command = [[%s/\s\+$//e]],
})

vim.g.vimwiki_global_ext = 0
vim.g.vimwiki_list = {
    {
      path = '~/vimwiki/',
      syntax = 'markdown',
      ext = '.md',
    }
}

vim.g.copilot_node_command = "~/.nvm/versions/node/v16.15.0/bin/node"
