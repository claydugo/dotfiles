return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master", -- pin to master for old API (main branch has breaking changes)
  build = ":TSUpdate",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "windwp/nvim-ts-autotag",
    { "nvim-treesitter/nvim-treesitter-textobjects", branch = "master" },
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

    require("nvim-treesitter.configs").setup({
      ensure_installed = ensure_installed,
      sync_install = false,
      auto_install = true,
      ignore_install = {},
      modules = {},
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<CR>",
          node_incremental = "<CR>",
          node_decremental = "<BS>",
          scope_incremental = "<Tab>",
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]f"] = "@function.outer",
            ["]c"] = "@class.outer",
            ["]a"] = "@parameter.inner",
          },
          goto_next_end = {
            ["]F"] = "@function.outer",
            ["]C"] = "@class.outer",
          },
          goto_previous_start = {
            ["[f"] = "@function.outer",
            ["[c"] = "@class.outer",
            ["[a"] = "@parameter.inner",
          },
          goto_previous_end = {
            ["[F"] = "@function.outer",
            ["[C"] = "@class.outer",
          },
        },
      },
    })

    -- Force treesitter re-highlight after external file changes
    vim.api.nvim_create_autocmd("FileChangedShellPost", {
      group = vim.api.nvim_create_augroup("treesitter_external_changes", { clear = true }),
      callback = function()
        vim.cmd("edit")
      end,
    })
  end,
}
