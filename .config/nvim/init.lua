require("options")
require("maps")

if not vim.g.vscode then
  require("config.lazy")
  require("maps_plugin")
end
