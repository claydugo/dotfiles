require("config.options")
require("config.maps")

if not vim.g.vscode then
    require("config.lazy")
    require("config.plugin_maps")
end
