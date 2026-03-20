return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "windwp/nvim-ts-autotag",
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  config = function()
    require("nvim-ts-autotag").setup()

    local ensure_installed = {
      "python",
      "lua",
      "wgsl",
      "cuda",
      "rust",
      "c",
      "bash",

      "html",
      "json",
      "qmldir",
      "luadoc",

      "desktop",
      "tmux",
      "ssh_config",
      "git_config",
      "git_rebase",
      "gitattributes",
      "gitcommit",
      "gitignore",
    }

    -- Only install Java/Gradle parsers if JDK is available (check for javac in PATH)
    if vim.fn.executable("javac") == 1 then
      table.insert(ensure_installed, "java")
      table.insert(ensure_installed, "groovy")
    end

    -- nvim-treesitter 1.x: highlight/indent are built into Neovim.
    -- tree-sitter-cli and compilers must be in the nvim pixi env.
    require("nvim-treesitter").setup()

    -- Auto-install missing parsers
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
      ["]f"] = function() ts_move.goto_next_start("@function.outer") end,
      ["]c"] = function() ts_move.goto_next_start("@class.outer") end,
      ["]a"] = function() ts_move.goto_next_start("@parameter.inner") end,
      ["]F"] = function() ts_move.goto_next_end("@function.outer") end,
      ["]C"] = function() ts_move.goto_next_end("@class.outer") end,
      ["[f"] = function() ts_move.goto_previous_start("@function.outer") end,
      ["[c"] = function() ts_move.goto_previous_start("@class.outer") end,
      ["[a"] = function() ts_move.goto_previous_start("@parameter.inner") end,
      ["[F"] = function() ts_move.goto_previous_end("@function.outer") end,
      ["[C"] = function() ts_move.goto_previous_end("@class.outer") end,
    }) do
      vim.keymap.set({ "n", "x", "o" }, key, fn)
    end

    -- Force treesitter re-highlight after external file changes
    vim.api.nvim_create_autocmd("FileChangedShellPost", {
      callback = function()
        vim.cmd("edit")
      end,
    })
  end,
}
