vim.g.loaded_gzip = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_remote_plugins = 1
vim.g.loaded_spellfile_plugin = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_tutor_mode_plugin = 1
vim.g.loaded_zipPlugin = 1

vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("pack_build_hooks", { clear = true }),
  callback = function(ev)
    local name = ev.data.spec.name
    local kind = ev.data.kind
    if name == "telescope-fzf-native.nvim" and (kind == "install" or kind == "update") then
      if vim.fn.has("win32") == 1 then
        vim
          .system({ "cmake", "-S.", "-Bbuild", "-G", "Ninja", "-DCMAKE_BUILD_TYPE=Release" }, { cwd = ev.data.path })
          :wait()
        vim.system({ "cmake", "--build", "build", "--config", "Release" }, { cwd = ev.data.path }):wait()
        vim.system({ "cmake", "--install", "build", "--prefix", "build" }, { cwd = ev.data.path }):wait()
      else
        vim.system({ "make" }, { cwd = ev.data.path }):wait()
      end
    elseif name == "nvim-treesitter" and kind == "update" then
      vim.schedule(function()
        if not ev.data.active then
          vim.cmd.packadd("nvim-treesitter")
        end
        vim.cmd("TSUpdate")
      end)
    end
  end,
})

local plugin_load_times = {}

local function load(name)
  local start = vim.uv.hrtime()
  local ok, err = pcall(function()
    local module = require("plugins." .. name)
    if module.specs then
      vim.pack.add(module.specs, { confirm = false })
    end
    if module.config then
      module.config()
    end
  end)
  if not ok then
    vim.schedule(function()
      vim.notify("plugins." .. name .. ": " .. err, vim.log.levels.ERROR)
    end)
  end
  plugin_load_times[name] = (vim.uv.hrtime() - start) / 1e6
end

-- Order matters: tokyonight before UI plugins, blink before lsp,
-- treesitter and mini before markdown.
load("tokyonight")
load("blink-cmp")
load("lsp")
load("treesitter")
load("mini")
load("markdown")
load("gitsigns")
load("telescope")
load("dropbar")
load("noice")
load("lazydev")
load("showtime")
load("browsher")
load("tip_of_my_buffer")

vim.api.nvim_create_user_command("PackProfile", function()
  local names = vim.tbl_keys(plugin_load_times)
  table.sort(names, function(a, b)
    return plugin_load_times[a] > plugin_load_times[b]
  end)
  local lines = {}
  for _, name in ipairs(names) do
    table.insert(lines, string.format("%8.2f ms  %s", plugin_load_times[name], name))
  end
  print(table.concat(lines, "\n"))
end, {})

vim.keymap.set("n", "<leader>l", function()
  vim.pack.update()
end)
