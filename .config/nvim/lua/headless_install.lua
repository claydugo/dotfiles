local packages = require("packages")

local M = {}

function M.run()
  require("lazy").load({ plugins = { "nvim-treesitter", "mason.nvim" } })

  local parsers = vim.list_extend({}, packages.treesitter)
  if vim.fn.executable("javac") == 1 then
    vim.list_extend(parsers, packages.treesitter_java)
  end

  print("Installing Treesitter parsers...")
  local ts_install = require("nvim-treesitter.install")
  local ok, err = ts_install.install(parsers, { force = true, summary = true }):pwait(300000)
  if not ok then
    print("Treesitter install error: " .. tostring(err))
  end

  local mason_packages = vim.list_extend({}, packages.mason)
  if vim.fn.executable("javac") == 1 then
    vim.list_extend(mason_packages, packages.mason_java)
  end

  print("Installing Mason packages...")
  vim.cmd("silent! MasonInstall " .. table.concat(mason_packages, " "))
end

return M
