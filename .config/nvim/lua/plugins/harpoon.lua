local function harpoon_picker()
  local harpoon = require("harpoon")
  local list = harpoon:list()
  if not list or not list.items then
    return
  end
  local file_paths = {}
  for _, item in ipairs(list.items) do
    table.insert(file_paths, item.value)
  end

  local conf = require("telescope.config").values
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

local keys = {
  { "<leader>h", harpoon_picker, desc = "Harpoon picker" },
  {
    "<leader>aa",
    function()
      require("harpoon"):list():add()
    end,
    desc = "Harpoon add file",
  },
  {
    "<leader>ah",
    function()
      local harpoon = require("harpoon")
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end,
    desc = "Harpoon quick menu",
  },
}

for i = 1, 9 do
  table.insert(keys, {
    "<leader>" .. i,
    function()
      require("harpoon"):list():select(i)
    end,
    desc = "Harpoon file " .. i,
  })
end

return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = keys,
  config = function()
    require("harpoon"):setup({})
  end,
}
