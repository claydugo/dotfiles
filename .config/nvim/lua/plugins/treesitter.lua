return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "windwp/nvim-ts-autotag",
    { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
  },
  config = function()
    require("nvim-ts-autotag").setup()

    local packages = require("packages")
    local ensure_installed = vim.list_extend({}, packages.treesitter)

    -- Only install Java/Gradle parsers if JDK is available
    if vim.fn.executable("javac") == 1 then
      vim.list_extend(ensure_installed, packages.treesitter_java)
    end

    -- nvim-treesitter 1.x: highlight/indent are built into Neovim.
    -- tree-sitter-cli and compilers must be in the nvim pixi env.
    require("nvim-treesitter").setup()

    -- Enable treesitter highlighting for all buffers with a parser
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter_highlight", { clear = true }),
      callback = function(args)
        if pcall(vim.treesitter.start, args.buf) then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })

    -- Auto-install missing parsers (skip in headless; headless_install.lua handles it)
    if #vim.api.nvim_list_uis() > 0 then
      local installed = require("nvim-treesitter").get_installed()
      local installed_set = {}
      for _, p in ipairs(installed) do
        installed_set[p] = true
      end
      local to_install = {}
      for _, p in ipairs(ensure_installed) do
        if not installed_set[p] then
          table.insert(to_install, p)
        end
      end
      if #to_install > 0 then
        require("nvim-treesitter").install(to_install)
      end
    end

    -- Textobjects (1.x API: config is separate from keymaps)
    require("nvim-treesitter-textobjects").setup({
      select = { lookahead = true },
      move = { set_jumps = true },
    })

    local ts_select = require("nvim-treesitter-textobjects.select")
    for key, query in pairs({
      ["af"] = "@function.outer",
      ["if"] = "@function.inner",
      ["ac"] = "@class.outer",
      ["ic"] = "@class.inner",
      ["aa"] = "@parameter.outer",
      ["ia"] = "@parameter.inner",
    }) do
      vim.keymap.set({ "x", "o" }, key, function()
        ts_select.select_textobject(query)
      end)
    end

    local ts_move = require("nvim-treesitter-textobjects.move")
    for key, fn in pairs({
      ["]f"] = function()
        ts_move.goto_next_start("@function.outer")
      end,
      ["]c"] = function()
        ts_move.goto_next_start("@class.outer")
      end,
      ["]a"] = function()
        ts_move.goto_next_start("@parameter.inner")
      end,
      ["]F"] = function()
        ts_move.goto_next_end("@function.outer")
      end,
      ["]C"] = function()
        ts_move.goto_next_end("@class.outer")
      end,
      ["[f"] = function()
        ts_move.goto_previous_start("@function.outer")
      end,
      ["[c"] = function()
        ts_move.goto_previous_start("@class.outer")
      end,
      ["[a"] = function()
        ts_move.goto_previous_start("@parameter.inner")
      end,
      ["[F"] = function()
        ts_move.goto_previous_end("@function.outer")
      end,
      ["[C"] = function()
        ts_move.goto_previous_end("@class.outer")
      end,
    }) do
      vim.keymap.set({ "n", "x", "o" }, key, fn)
    end

    -- Force treesitter re-highlight after external file changes
    vim.api.nvim_create_autocmd("FileChangedShellPost", {
      group = vim.api.nvim_create_augroup("treesitter_external_changes", { clear = true }),
      callback = function()
        vim.cmd("edit")
      end,
    })
  end,
}
