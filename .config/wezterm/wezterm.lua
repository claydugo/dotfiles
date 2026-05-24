local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.font = wezterm.font("GoogleSansCode Nerd Font Mono")
config.font_size = 12.0
config.freetype_load_target = "Normal"
config.freetype_render_target = "HorizontalLcd"
config.term = "xterm-256color"
config.window_background_opacity = 1.0
config.window_padding = { left = 6, right = 6, top = 6, bottom = 6 }
config.window_decorations = "TITLE | RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.scrollback_lines = 100000
config.default_cursor_style = "SteadyBlock"
config.audible_bell = "Disabled"

config.colors = {
  foreground = "#c0caf5",
  background = "#1a1b26",
  cursor_bg = "#c0caf5",
  cursor_fg = "#1a1b26",
  cursor_border = "#c0caf5",
  selection_bg = "#283457",
  selection_fg = "#c0caf5",
  ansi = { "#15161e", "#f7768e", "#9ece6a", "#e0af68", "#7aa2f7", "#bb9af7", "#7dcfff", "#a9b1d6" },
  brights = { "#414868", "#f7768e", "#9ece6a", "#e0af68", "#7aa2f7", "#bb9af7", "#7dcfff", "#c0caf5" },
}

if wezterm.target_triple:find("windows") then
  config.default_prog = { "pwsh.exe", "-NoLogo" }
end

return config
