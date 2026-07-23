local M = {
  specs = {
    { src = "https://github.com/echasnovski/mini.nvim" },
  },
}

local function get_LSP()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if not next(clients) then
    return ""
  end
  local icons = require("langserver_icons")
  local lsp_names = {}
  for _, client in pairs(clients) do
    table.insert(lsp_names, icons and icons[client.name] or client.name)
  end
  return table.concat(lsp_names, " ")
end

local function search_display()
  local search = vim.fn.searchcount({ maxcount = 0 })
  local search_term = vim.fn.getreg("/")
  if search.current > 0 then
    return string.format("/%s [%d/%d]", search_term, search.current, search.total)
  else
    return ""
  end
end

local function diagnostics_display()
  local counts = vim.diagnostic.count(0)
  local parts = {}
  for _, item in ipairs({
    { vim.diagnostic.severity.ERROR, "%#MiniStatuslineDiagnosticError#󰅚 " },
    { vim.diagnostic.severity.WARN, "%#MiniStatuslineDiagnosticWarn#󰀪 " },
    { vim.diagnostic.severity.INFO, "%#MiniStatuslineDiagnosticInfo#󰋽 " },
    { vim.diagnostic.severity.HINT, "%#MiniStatuslineDiagnosticHint#󰌶 " },
  }) do
    local count = counts[item[1]]
    if count then
      table.insert(parts, item[2] .. count)
    end
  end
  return table.concat(parts, " ")
end

local left_separator = ""
local right_separator = ""

local function filename_display()
  local name = vim.fn.expand("%:t")
  if name == "" then
    name = "[No Name]"
  end
  local flags = ""
  if vim.bo.modified then
    flags = flags .. "[+]"
  end
  if not vim.bo.modifiable or vim.bo.readonly then
    flags = flags .. "[-]"
  end
  return name:gsub("%%", "%%%%") .. (flags ~= "" and " " .. flags or "")
end

local function statusline_active()
  local statusline = require("mini.statusline")
  local mode, mode_hl = statusline.section_mode({})
  local accent_hl = mode_hl:gsub("Mode", "Accent")
  local lsp = get_LSP()
  local search = search_display()
  local groups = {
    { hl = mode_hl, strings = { mode:upper() } },
    "%#" .. accent_hl .. "#" .. left_separator,
    { hl = accent_hl, strings = { filename_display() } },
    "%#MiniStatuslineSeparator#" .. left_separator,
    { hl = "StatusLine", strings = { diagnostics_display() } },
    "%<",
    "%=",
  }
  if lsp ~= "" then
    table.insert(groups, "%#MiniStatuslineSeparator#" .. right_separator)
    table.insert(groups, { hl = accent_hl, strings = { lsp } })
  end
  if search ~= "" then
    local separator_hl = lsp ~= "" and accent_hl or mode_hl:gsub("Mode", "Edge")
    table.insert(groups, "%#" .. separator_hl .. "#" .. right_separator)
    table.insert(groups, { hl = mode_hl, strings = { search } })
  end
  return statusline.combine_groups(groups)
end

-- Accent groups: mode color as fg on the gray section bg (lualine b-section
-- look). Diagnostic groups: severity fg on the plain statusline bg.
local function define_statusline_groups()
  local devinfo_bg = vim.api.nvim_get_hl(0, { name = "MiniStatuslineDevinfo", link = false }).bg
  local statusline_bg = vim.api.nvim_get_hl(0, { name = "StatusLine", link = false }).bg
  -- Separator glyph: fg is the bg of the section it points out of.
  vim.api.nvim_set_hl(0, "MiniStatuslineSeparator", { fg = devinfo_bg, bg = statusline_bg })
  for _, name in ipairs({ "Normal", "Insert", "Visual", "Replace", "Command", "Other" }) do
    local mode = vim.api.nvim_get_hl(0, { name = "MiniStatuslineMode" .. name, link = false })
    vim.api.nvim_set_hl(0, "MiniStatuslineMode" .. name, { fg = mode.fg, bg = mode.bg })
    vim.api.nvim_set_hl(0, "MiniStatuslineAccent" .. name, { fg = mode.bg, bg = devinfo_bg })
    vim.api.nvim_set_hl(0, "MiniStatuslineEdge" .. name, { fg = mode.bg, bg = statusline_bg })
  end
  for name, source in pairs({
    Error = "DiagnosticError",
    Warn = "DiagnosticWarn",
    Info = "DiagnosticInfo",
    Hint = "DiagnosticHint",
  }) do
    local severity_fg = vim.api.nvim_get_hl(0, { name = source, link = false }).fg
    vim.api.nvim_set_hl(0, "MiniStatuslineDiagnostic" .. name, { fg = severity_fg, bg = statusline_bg })
  end
end

function M.config()
  -- require("mini.starter").setup({
  -- 	items = { { name = "", action = "", section = "" } },
  -- 	header = "",
  -- 	footer = "",
  -- 	silent = true,
  -- })
  require("mini.hipatterns").setup({
    highlighters = {
      hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
      todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
      clay = { pattern = "%f[%w]()Clay()%f[%W]", group = "MiniHipatternsTodo" },
      hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
    },
  })
  require("mini.trailspace").setup()
  require("mini.statusline").setup({
    content = { active = statusline_active },
  })
  define_statusline_groups()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("statusline_groups", { clear = true }),
    callback = define_statusline_groups,
  })
end

return M
