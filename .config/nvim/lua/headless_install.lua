local packages = require("packages")

local M = {}

function M.run()
  require("lazy").load({ plugins = { "nvim-treesitter", "mason.nvim" } })

  local parsers = vim.list_extend({}, packages.treesitter)
  if vim.fn.executable("javac") == 1 then
    vim.list_extend(parsers, packages.treesitter_java)
  end

  print("Installing Treesitter parsers...")
  vim.cmd("TSInstallSync " .. table.concat(parsers, " "))

  local mason_packages = vim.list_extend({}, packages.mason)
  if vim.fn.executable("javac") == 1 then
    vim.list_extend(mason_packages, packages.mason_java)
  end

  print("Installing Mason packages...")
  vim.cmd("MasonInstall " .. table.concat(mason_packages, " "))

  print("Headless installation complete!")
end

return M
