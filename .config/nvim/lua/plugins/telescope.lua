local M = {
  "nvim-telescope/telescope.nvim",
  cmd = { "Telescope" },
  keys = {
    {
      "<leader>f",
      function()
        require("telescope.builtin").find_files({ hidden = true })
      end,
      desc = "Find files",
    },
    {
      "<leader>g",
      function()
        require("telescope.builtin").live_grep()
      end,
      desc = "Live grep",
    },
    {
      "<leader>d",
      function()
        require("telescope.builtin").lsp_definitions()
      end,
      desc = "LSP definitions",
    },
    {
      "<leader>t",
      function()
        require("telescope.builtin").lsp_type_definitions()
      end,
      desc = "LSP type definitions",
    },
  },
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    { "nvim-treesitter/nvim-treesitter" },
    { "ThePrimeagen/harpoon", branch = "harpoon2" },
    { "debugloop/telescope-undo.nvim" },
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    { "nvim-telescope/telescope-ui-select.nvim" },
  },
}

function M.config()
  local tele = require("telescope")
  local actions = require("telescope.actions")
  tele.setup({
    defaults = {
      -- sorting_strategy = "ascending",
      layout_config = {
        horizontal = {
          prompt_position = "top",
        },
        vertical = {
          prompt_position = "top",
        },
      },
      prompt_prefix = "🔬 ",
      path_display = { "truncate" },
      file_ignore_patterns = {
        "%.jpg",
        "%.jpeg",
        "%.png",
        "%.mp4",
        "%.nc",
        "%.tif",
        "%.bmp",
        "%.cpython",
        "%.npy",
        "%.ipynb",
        "%.ui",
        "%.fig",
        "%.xls",
        "%.ttf",
        "%.pdf",
        "%.bin",
        ".git/",
        "%.class", -- Java compiled files
        "build/", -- Gradle build directory
      },
      mappings = {
        i = {
          ["<RightMouse>"] = actions.close,
          ["<LeftMouse>"] = actions.select_default,
          ["<ScrollWheelDown>"] = actions.move_selection_next,
          ["<ScrollWheelUp>"] = actions.move_selection_previous,
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
          ["<ESC>"] = actions.close,
        },
        n = {
          ["<Esc>"] = actions.close,
        },
      },
      vimgrep_arguments = {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        "--hidden",
      },
      color_devicons = false,
    },
    pickers = {
      find_files = {
        find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
        disable_devicons = true,
      },
      live_grep = {
        disable_devicons = true,
      },
    },
    extensions = {
      ["ui-select"] = {
        require("telescope.themes").get_dropdown({}),
      },
    },
  })
  tele.load_extension("fzf")
  tele.load_extension("undo")
  tele.load_extension("ui-select")

  local harpoon = require("harpoon")
  harpoon:setup({})
  local conf = require("telescope.config").values
  local function toggle_telescope(harpoon_files)
    if not harpoon_files or not harpoon_files.items then
      return
    end
    local file_paths = {}
    for _, item in ipairs(harpoon_files.items) do
      table.insert(file_paths, item.value)
    end

    require("telescope.pickers")
      .new({}, {
        prompt_title = "Harpoon",
        finder = require("telescope.finders").new_table({
          results = file_paths,
        }),
        previewer = conf.file_previewer({}),
        sorter = conf.generic_sorter({}),
      })
      :find()
  end

  vim.keymap.set("n", "<leader>h", function()
    toggle_telescope(harpoon:list())
  end)
  vim.keymap.set("n", "<leader>aa", function()
    harpoon:list():add()
  end)
  vim.keymap.set("n", "<leader>ah", function()
    harpoon.ui:toggle_quick_menu(harpoon:list())
  end)

  for i = 1, 9 do
    vim.keymap.set("n", "<leader>" .. i, function()
      harpoon:list():select(i)
    end)
  end
end

-- Runs at startup before plugin loads
function M.init()
  vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("telescope_startup", { clear = true }),
    callback = function()
      local arg = vim.fn.argv(0)
      if arg and (vim.fn.isdirectory(arg) ~= 0 or arg == "") then
        vim.defer_fn(function()
          if vim.bo[0].filetype ~= "netrw" then
            require("telescope.builtin").find_files({ hidden = true })
          end
        end, 100)
      end
    end,
  })
end

return M
