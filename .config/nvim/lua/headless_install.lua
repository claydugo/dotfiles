local packages = require("packages")

local M = {}

function M.run()
  local successful = true
  local parsers = packages.treesitter

  print("Installing Treesitter parsers...")
  local ts_install = require("nvim-treesitter.install")
  local ok, installed = ts_install.install(parsers, { force = true, summary = true }):pwait(300000)
  if not ok then
    print("Treesitter install error: " .. tostring(installed))
    successful = false
  elseif not installed then
    print("Treesitter install failed for some parsers")
    successful = false
  end

  local mason_packages = packages.mason

  print("Installing Mason packages...")
  local registry = require("mason-registry")

  local refreshed = false
  local refresh_successful = false
  registry.refresh(function(success)
    refreshed = true
    refresh_successful = success
  end)
  local refresh_completed = vim.wait(30000, function()
    return refreshed
  end, 100)
  if not refresh_completed or not refresh_successful then
    print("Mason registry refresh failed or timed out")
    return false
  end

  local done = 0
  local total = #mason_packages
  for _, pkg_name in ipairs(mason_packages) do
    local pkg_ok, pkg = pcall(registry.get_package, pkg_name)
    if not pkg_ok then
      print("  ✗ " .. pkg_name .. " not found in registry")
      successful = false
      done = done + 1
    elseif pkg:is_installed() then
      print("  ✓ " .. pkg_name .. " (already installed)")
      done = done + 1
    else
      local handle = pkg:install()
      handle:once(
        "closed",
        vim.schedule_wrap(function()
          done = done + 1
          if pkg:is_installed() then
            print("  ✓ " .. pkg_name .. " installed (" .. done .. "/" .. total .. ")")
          else
            print("  ✗ " .. pkg_name .. " failed to install")
            successful = false
          end
        end)
      )
    end
  end

  -- Wait for all Mason installations to complete
  local completed = vim.wait(300000, function()
    return done >= total
  end, 1000)
  if not completed then
    print("Mason package installation timed out")
  end
  return successful and completed
end

return M
