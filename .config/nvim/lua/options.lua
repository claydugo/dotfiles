vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.grepprg = "rg --vimgrep"
vim.o.grepformat = "%f:%l:%c:%m"

vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.completeopt:append("fuzzy")
vim.opt.completeopt:append("nearest")

vim.o.writebackup = false
vim.o.swapfile = false
vim.o.undofile = true
vim.o.confirm = true
vim.o.clipboard = "unnamedplus"
vim.opt.jumpoptions = "stack,view"

vim.o.updatetime = 300
vim.o.ignorecase = true
vim.o.smartcase = true
vim.opt.shortmess:append("S")
vim.opt.shortmess:append("WIcC")

vim.o.autowrite = true
vim.o.modeline = false
vim.o.number = true
vim.o.relativenumber = true
vim.o.showmode = false
vim.o.scrolloff = 6

vim.o.showmatch = true

vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.smartindent = true
vim.o.expandtab = true

vim.o.ttimeoutlen = 5
vim.o.timeoutlen = 1000

vim.o.spellfile = vim.fs.joinpath(vim.fn.stdpath("config"), "spell", "en.utf-8.add")

vim.o.winborder = "rounded"
vim.o.pumheight = 5
vim.o.pumblend = 20

vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

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

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  callback = function(args)
    if args.match:match("^%w+://") then
      return
    end
    local dir = vim.fn.fnamemodify(args.match, ":p:h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function(args)
    vim.schedule(function()
      if
        not vim.api.nvim_buf_is_valid(args.buf)
        or vim.api.nvim_get_current_buf() ~= args.buf
        or vim.tbl_contains({ "gitcommit", "gitrebase", "jj" }, vim.bo[args.buf].filetype)
      then
        return
      end
      local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
      if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(args.buf) then
        pcall(vim.api.nvim_win_set_cursor, 0, mark)
      end
    end)
  end,
})

-- Conda recipes are Jinja-templated yaml; the yaml treesitter grammar chokes
-- on the template tags (whole-file ERROR node, no highlights). Parse them
-- with the jinja grammar instead and inject yaml into the content nodes
-- (see after/queries/jinja/injections.scm).
vim.filetype.add({
  pattern = {
    [".*/recipe/meta%.ya?ml"] = "yaml.jinja",
  },
})
vim.treesitter.language.register("jinja", "yaml.jinja")

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
