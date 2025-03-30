-- Oil config

-- Add this to make oil open in a floating window by default

local oil = require("oil")

-- Oil config

--- vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

local oil = require("oil")

oil.setup({
	keymaps = {
		["g?"] = { "actions.show_help", mode = "n" },
		["<CR>"] = "actions.select",
		["<C-s>"] = { "actions.select", opts = { vertical = true } },
		["<C-h>"] = { "actions.select", opts = { horizontal = true } },
		["<C-t>"] = { "actions.select", opts = { tab = true } },
		["<C-p>"] = { "actions.preview", opts = { use_float = true } },
		["<C-c>"] = { "actions.close", mode = "n" },
		["<C-l>"] = "actions.refresh",
		["-"] = { "actions.parent", mode = "n" },
		["_"] = { "actions.open_cwd", mode = "n" },
		["`"] = { "actions.cd", mode = "n" },
		["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
		["gs"] = { "actions.change_sort", mode = "n" },
		["gx"] = "actions.open_external",
		["g."] = { "actions.toggle_hidden", mode = "n" },
		["g\\"] = { "actions.toggle_trash", mode = "n" }
	},


	view_options = {
		-- Show file preview in a floating window
		show_hidden = false,
		-- Configuration for the floating preview window
		preview = {
			use_float = true,
			float_opts = {
				border = "rounded",
				winblend = 15,
				width = 40,
				winhighlight = "Normal:OilFloat",  -- Custom highlight group
				height = 20,
				relative = "cursor",
				row = 0,
				col = 1,
			},
		},
	},

	-- Make sure the main oil buffer opens as a floating window
	-- Add this to open oil itself in a floating window
	default_file_explorer = true,
	use_float = true, -- Set this to true to use floating windows by default

	default_file_explorer = true,
	columns = {
		"icon",
	},
	buf_options = {
		buflisted = false,
		bufhidden = "hide",
	},
	win_options = {
		wrap = false,
		signcolumn = "no",
		cursorcolumn = false,
		foldcolumn = "0",
		spell = false,
		list = false,
		conceallevel = 3,
		concealcursor = "nvic",
	},
	delete_to_trash = false,
	skip_confirm_for_simple_edits = false,
	prompt_save_on_select_new_entry = true,
	cleanup_delay_ms = 2000,
	lsp_file_methods = {
		timeout_ms = 1000,
		autosave_changes = false,
	},
	constrain_cursor = "editable",
	watch_for_changes = false,
	use_default_keymaps = true,
	extra_scp_args = {},
	float = {
		padding = 6,
		max_width = 0.5,
		max_height = 0,
		border = "rounded",
		win_options = {
			winblend = 20,
		},
    winhighlight = "Normal:OilFloat",  -- Custom highlight group
		preview_split = "auto",
		override = function(conf)
			return conf
		end,
	},

	preview = {
		max_width = 0.9,
		min_width = { 40, 0.4 },
		width = nil,
		max_height = 0.9,
		min_height = { 5, 0.1 },
		height = nil,
		border = "rounded",
		win_options = {
			winblend = 15,
		},
		update_on_cursor_moved = true,
	},
	preview_win_opts = {
		is_floating = true,
		border = "rounded",
		winblend = 15,
		relative = "cursor",
		row = 1,
		col = 0,
	},
	progress = {
		max_width = 0.4,
		min_width = { 40, 0.4 },
		width = nil,
		max_height = { 10, 0.7 },
		min_height = { 5, 0.1 },
		height = nil,
		border = "rounded",
		minimized_border = "rounded",
		win_options = {
			winblend = 15,
		},
	},
	ssh = {
		border = "rounded",
	},
	keymaps_help = {
		border = "rounded",
	},
})

vim.keymap.set("n", "-", function()
  oil.open_float()
end, { desc = "Open parent directory in float" })

-- Create blcoking background for oil
vim.api.nvim_create_autocmd("FileType", {
	pattern = "oil",
	callback = function()
		vim.cmd("setlocal winhighlight=Normal:OilFloat")
	end,
})

