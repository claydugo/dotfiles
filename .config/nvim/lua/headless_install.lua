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
  local registry = require("mason-registry")

  local refreshed = false
  registry.refresh(function()
    refreshed = true
  end)
  vim.wait(30000, function()
    return refreshed
  end, 100)

  local done = 0
  local total = #mason_packages
  for _, pkg_name in ipairs(mason_packages) do
    local pkg_ok, pkg = pcall(registry.get_package, pkg_name)
    if not pkg_ok then
      print("  ✗ " .. pkg_name .. " not found in registry")
      done = done + 1
    elseif pkg:is_installed() then
      print("  ✓ " .. pkg_name .. " (already installed)")
      done = done + 1
    else
      local handle = pkg:install()
      handle:once("closed", vim.schedule_wrap(function()
        done = done + 1
        if pkg:is_installed() then
          print("  ✓ " .. pkg_name .. " installed (" .. done .. "/" .. total .. ")")
        else
          print("  ✗ " .. pkg_name .. " failed to install")
        end
      end))
    end
  end

  -- Wait for all Mason installations to complete
  vim.wait(300000, function()
    return done >= total
  end, 1000)
end

return M
