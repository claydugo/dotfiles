local M = {
	"nvim-telescope/telescope.nvim",
	-- dir = "~/projects/telescope.nvim/",
	lazy = false,
	cmd = { "Telescope" },
	dependencies = {
		{ "nvim-lua/plenary.nvim" },
		{ "ThePrimeagen/harpoon", branch = "harpoon2" },
		{ "debugloop/telescope-undo.nvim" },
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
			-- selection_caret = " ",
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
			},
			mappings = {
				-- insert mode mappings
				i = {
					["<RightMouse>"] = actions.close,
					["<LeftMouse>"] = actions.select_default,
					["<ScrollWheelDown>"] = actions.move_selection_next,
					["<ScrollWheelUp>"] = actions.move_selection_previous,
					["<C-j>"] = actions.move_selection_next,
					["<C-k>"] = actions.move_selection_previous,
					["<ESC>"] = actions.close,
				},
				-- normal mode mappings
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
			shorten_path = true,
			-- borderchars = { " ", " ", " ", " ", " ", " ", " ", " " },
		},
		pickers = {
			find_files = {
				disable_devicons = true,
			},
			live_grep = {
				disable_devicons = true,
			},
		},
	})
	tele.load_extension("undo")

	local harpoon = require("harpoon")
	harpoon:setup({})
	local conf = require("telescope.config").values
	local function toggle_telescope(harpoon_files)
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
	vim.keymap.set("n", "<leader>1", function()
		harpoon:list():select(1)
	end)
	vim.keymap.set("n", "<leader>2", function()
		harpoon:list():select(2)
	end)
	vim.keymap.set("n", "<leader>3", function()
		harpoon:list():select(3)
	end)
	vim.keymap.set("n", "<leader>4", function()
		harpoon:list():select(4)
	end)
	vim.keymap.set("n", "<leader>5", function()
		harpoon:list():select(5)
	end)
	vim.keymap.set("n", "<leader>6", function()
		harpoon:list():select(6)
	end)
	vim.keymap.set("n", "<leader>7", function()
		harpoon:list():select(7)
	end)
	vim.keymap.set("n", "<leader>8", function()
		harpoon:list():select(8)
	end)
	vim.keymap.set("n", "<leader>9", function()
		harpoon:list():select(9)
	end)
end

return M
