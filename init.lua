require("config.lazy")






-- Treesitter

require'nvim-treesitter.configs'.setup {
  ensure_installed = { "yaml", "markdown" }
}

-- API KEY
local function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function get_env_data()
	local env_file = vim.fn.getcwd() .. "/.env"
	local env_data = ""
	local file = io.open(env_file, "r")
	if file then
		env_data = file:read("*a")
		file:close()
	end
	-- print too
	local key = trim(env_data)
	return key
end

OPENAI_API_KEY = get_env_data()

-- AI

require("codecompanion").setup({
	strategies = {
		chat = {
			adapter = "openai",
			keymaps = {
				close = {
					modes = { n = "<C-x>", i = "<C-x>" },
				},
			},

		},
		inline = {
			adapter = "openai",
			keymaps = {
				accept_change = {
					modes = { n = "<Tab>" },
					description = "Accept the suggested change",
				},
				reject_change = {
					modes = { n = "<C-c>" },
					description = "Reject the suggested change",
				},
			},
		},
	},

	adapters = {
		openai = function()
			return require("codecompanion.adapters").extend("openai", {
				env = {
					api_key = OPENAI_API_KEY,  -- Ensure this returns a clean string
				},
				schema = {
					model = {
						default = "o1-mini",
					},
				},
			})
		end,
	},

  display = {
    action_palette = {
      width = 95,
      height = 10,
      prompt = "Prompt ",
      provider = "telescope",
      opts = {
        show_default_actions = true,
        show_default_prompt_library = true,
      },
    },
  },
})


vim.keymap.set({ "n", "v" }, "<C-a>", "<CMD>CodeCompanionActions<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<leader>aa", "<CMD>CodeCompanionChat Toggle<CR>", { noremap = true, silent = true })
vim.keymap.set("v", "<leader>af", "<CMD>CodeCompanionChat Add<CR>", { noremap = true, silent = true })

-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd[[cab cc CodeCompanion]]

-- Lua line
--
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    always_show_tabline = true,
    globalstatus = false,
    refresh = {
      statusline = 100,
      tabline = 100,
      winbar = 100,
    }
  },
  sections = {
    lualine_a = {},
    lualine_b = {},
		lualine_c = {},
		lualine_x = {},
    lualine_y = {},
    lualine_z = {},
	},
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {
    lualine_a = {'filename'},
    lualine_b = {'filetype', 'fileformat', 'encoding'},
    lualine_c = {
			{
			'datetime',
			style = "%b(%-d|%a)@%H:%M:%S", },

	},
    lualine_x = {'progress','location'},
    lualine_y = {'diagnostics','diff', 'branch'},
    lualine_z = {'mode'}
	},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}

-- null ls for prettier
local null_ls = require("null-ls")

null_ls.setup({
  debug = false, -- or true for debugging
  sources = {
    -- Use either `prettier` or `prettierd`, whichever you prefer
    null_ls.builtins.formatting.prettierd.with({
      filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "json",
        "yaml",
        "html",
        "css",
        "markdown"
        -- etc.
      },
      -- extra_args = { "--print-width", "80" }, -- optional
    }),
  },
  on_attach = function(client, bufnr)
    -- Keymap to manually format
    if client.supports_method("textDocument/formatting") then
      vim.keymap.set("n", "<leader>f", function()
        vim.lsp.buf.format({ bufnr = bufnr })
      end, { buffer = bufnr, desc = "Format with null-ls" })
    end

    -- Auto-format on save
    local group = vim.api.nvim_create_augroup("lsp_format_on_save", { clear = false })
    vim.api.nvim_clear_autocmds({ buffer = bufnr, group = group })
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      group = group,
      callback = function()
        vim.lsp.buf.format({ bufnr = bufnr }) -- or async = false/true
      end,
      desc = "Format on save with null-ls",
    })
  end,
})

-- Colors
--
vim.o.termguicolors = true  -- Enable true color support

require("nightfox").setup({
	options = {
		colorblind = {
			enable = true,
			-- simulate_only = true,
			severity = {
				-- protan = 1,
				-- deutan = 1,
				-- tritan = 1,
			}
		},
		transparent = true,
		terminal_colors = true,
		styles = {               -- Style to be applied to different syntax groups
			comments = "italic",     -- Value is any valid attr-list value `:help attr-list`
			conditionals = "italic",
			constants = "underdotted",
			functions = "bold",
			keywords = "italic",
			numbers = "italic",
			operators = "italic",
			strings = "italic",
			types = "bold",
			variables = "NONE",
		},
	},
})
vim.cmd[[colorscheme nightfox]]

require("nvim-highlight-colors").setup {
	---Render style
	---@usage 'background'|'foreground'|'virtual'
	render = 'background',

	---Set virtual symbol (requires render to be set to 'virtual')
	virtual_symbol = '■',

	---Set virtual symbol suffix (defaults to '')
	virtual_symbol_prefix = '',

	---Set virtual symbol suffix (defaults to ' ')
	virtual_symbol_suffix = ' ',

	---Set virtual symbol position()
 	---@usage 'inline'|'eol'|'eow'
 	---inline mimics VS Code style
 	---eol stands for `end of column` - Recommended to set `virtual_symbol_suffix = ''` when used.
 	---eow stands for `end of word` - Recommended to set `virtual_symbol_prefix = ' ' and virtual_symbol_suffix = ''` when used.
	virtual_symbol_position = 'inline',

	---Highlight hex colors, e.g. '#FFFFFF'
	enable_hex = true,

    	---Highlight short hex colors e.g. '#fff'
	enable_short_hex = true,

	---Highlight rgb colors, e.g. 'rgb(0 0 0)'
	enable_rgb = true,

	---Highlight hsl colors, e.g. 'hsl(150deg 30% 40%)'
	enable_hsl = true,

	---Highlight CSS variables, e.g. 'var(--testing-color)'
	enable_var_usage = true,

	---Highlight named colors, e.g. 'green'
	enable_named_colors = true,

	---Highlight tailwind colors, e.g. 'bg-blue-500'
	enable_tailwind = false,

	---Set custom colors
	---Label must be properly escaped with '%' to adhere to `string.gmatch`
	--- :help string.gmatch
	custom_colors = {
		{ label = '%-%-theme%-primary%-color', color = '#0f1219' },
		{ label = '%-%-theme%-secondary%-color', color = '#5a5d64' },
	},

 	-- Exclude filetypes or buftypes from highlighting e.g. 'exclude_buftypes = {'text'}'
    	exclude_filetypes = {},
    	exclude_buftypes = {}
}
-- Fugative config

vim.keymap.set("n", "<leader>gs", ":Git<CR>", { desc = "Open Git status" })
vim.keymap.set("n", "<leader>gc", ":Git commit -m '", { desc = "Open Git commit" })
vim.keymap.set("n", "<leader>ga", ":Git add -u<CR>'", { desc = "Open Git add" })
vim.keymap.set("n", "<leader>gq", ":Git add ", { desc = "Open Git add" })
vim.keymap.set("n", "<leader>gp", ":Git pull<CR>", { desc = "Open Git pull" })
vim.keymap.set("n", "<leader>gf", ":Git push<CR>", { desc = "Open Git push" })
vim.keymap.set("n", "<leader>gh", ":Gdiffsplit<CR>", { desc = "Open Git diff" })
vim.keymap.set("n", "<leader>gg", ":Git difftool<CR>", { desc = "Open Git diff" })
vim.keymap.set("n", "]g", "<cmd>cnext<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "[g", "<cmd>cprev<CR>", { noremap = true, silent = true })

-- Baseic config

vim.keymap.set('n', '<C-[>', '<C-w>h', { noremap = true, silent = true })
vim.keymap.set('n', '<C-h>', '<C-w>h', { noremap = true, silent = true })
vim.keymap.set('n', '<C-j>', '<C-w>j', { noremap = true, silent = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { noremap = true, silent = true })
vim.keymap.set('n', '<C-l>', '<C-w>l', { noremap = true, silent = true })

-- Window splitting (right and down)
vim.keymap.set('n', '<leader>wd', '<C-w>s', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>wf', '<C-w>v', { noremap = true, silent = true })


vim.opt.clipboard:append { 'unnamedplus' }


-- Harpoon config

local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

vim.keymap.set("n", "<leader>a", mark.add_file)
vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu)

vim.keymap.set("n", "<C-t>", function() ui.nav_file(1) end)
vim.keymap.set("n", "<C-y>", function() ui.nav_file(2) end)
vim.keymap.set("n", "<C-n>", function() ui.nav_file(3) end)
vim.keymap.set("n", "<C-s>", function() ui.nav_file(4) end)


-- Oil config

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

require("oil").setup({
	keymaps = {
		["g?"] = { "actions.show_help", mode = "n" },
    ["<CR>"] = "actions.select",
    ["<C-]>"] = { "actions.select", opts = { vertical = true } },
    ["<C-h>"] = { "actions.select", opts = { horizontal = true } },
    ["<C-t>"] = { "actions.select", opts = { tab = true } },
    ["<C-p>"] = "actions.preview",
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

	-- Oil will take over directory buffers (e.g. `vim .` or `:e src/`)
	-- Set to false if you want some other plugin (e.g. netrw) to open when you edit directories.
	default_file_explorer = true,
	-- Id is automatically added at the beginning, and name at the end
	-- See :help oil-columns
	columns = {
		"icon",
		-- "permissions",
		-- "size",
		-- "mtime",
	},

	-- Buffer-local options to use for oil buffers
	buf_options = {
		buflisted = false,
		bufhidden = "hide",
	},

	-- Window-local options to use for oil buffers
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
	-- Send deleted files to the trash instead of permanently deleting them (:help oil-trash)
	delete_to_trash = false,
	-- Skip the confirmation popup for simple operations (:help oil.skip_confirm_for_simple_edits)
	skip_confirm_for_simple_edits = false,
	-- Selecting a new/moved/renamed file or directory will prompt you to save changes first
	-- (:help prompt_save_on_select_new_entry)
	prompt_save_on_select_new_entry = true,
	-- Oil will automatically delete hidden buffers after this delay
	-- You can set the delay to false to disable cleanup entirely
	-- Note that the cleanup process only starts when none of the oil buffers are currently displayed
	cleanup_delay_ms = 2000,
	lsp_file_methods = {
		-- Time to wait for LSP file operations to complete before skipping
		timeout_ms = 1000,
		-- Set to true to autosave buffers that are updated with LSP willRenameFiles
		-- Set to "unmodified" to only save unmodified buffers
		autosave_changes = false,
	},
	-- Constrain the cursor to the editable parts of the oil buffer
	-- Set to `false` to disable, or "name" to keep it on the file names
	constrain_cursor = "editable",
	-- Set to true to watch the filesystem for changes and reload oil
	watch_for_changes = false,
	-- Keymaps in oil buffer. Can be any value that `vim.keymap.set` accepts OR a table of keymap
	-- options with a `callback` (e.g. { callback = function() ... end, desc = "", mode = "n" })
	-- Additionally, if it is a string that matches "actions.<name>",
	-- it will use the mapping at require("oil.actions").<name>
	-- Set to `false` to remove a keymap
	-- See :help oil-actions for a list of all available actions
	keymaps = {
		["g?"] = "actions.show_help",
		["<CR>"] = "actions.select",
		["<C-s>"] = { "actions.select", opts = { vertical = true }, desc = "Open the entry in a vertical split" },
		["<C-h>"] = { "actions.select", opts = { horizontal = true }, desc = "Open the entry in a horizontal split" },
		["<C-t>"] = { "actions.select", opts = { tab = true }, desc = "Open the entry in new tab" },
		["<C-p>"] = "actions.preview",
		["<C-c>"] = "actions.close",
		["<C-l>"] = "actions.refresh",
		["-"] = "actions.parent",
		["_"] = "actions.open_cwd",
		["`"] = "actions.cd",
		["~"] = { "actions.cd", opts = { scope = "tab" }, desc = ":tcd to the current oil directory" },
		["gs"] = "actions.change_sort",
		["gx"] = "actions.open_external",
		["g."] = "actions.toggle_hidden",
		["g\\"] = "actions.toggle_trash",
	},
	-- Set to false to disable all of the above keymaps
	use_default_keymaps = true,
	view_options = {
		-- Show files and directories that start with "."
		show_hidden = false,
		-- This function defines what is considered a "hidden" file
		is_hidden_file = function(name, bufnr)
			return vim.startswith(name, ".")
		end,
		-- This function defines what will never be shown, even when `show_hidden` is set
		is_always_hidden = function(name, bufnr)
			return false
		end,
		-- Sort file names in a more intuitive order for humans. Is less performant,
		-- so you may want to set to false if you work with large directories.
		natural_order = true,
		-- Sort file and directory names case insensitive
		case_insensitive = false,
		sort = {
			-- sort order can be "asc" or "desc"
			-- see :help oil-columns to see which columns are sortable
			{ "type", "asc" },
			{ "name", "asc" },
		},
	},
	-- Extra arguments to pass to SCP when moving/copying files over SSH
	extra_scp_args = {},
	-- EXPERIMENTAL support for performing file operations with git
	git = {
		-- Return true to automatically git add/mv/rm files
		add = function(path)
			return false
		end,
		mv = function(src_path, dest_path)
			return false
		end,
		rm = function(path)
			return false
		end,
	},
	-- Configuration for the floating window in oil.open_float
	float = {
		-- Padding around the floating window
		padding = 2,
		max_width = 0,
		max_height = 0,
		border = "rounded",
		win_options = {
			winblend = 0,
		},
		-- preview_split: Split direction: "auto", "left", "right", "above", "below".
		preview_split = "auto",
		-- This is the config that will be passed to nvim_open_win.
		-- Change values here to customize the layout
		override = function(conf)
			return conf
		end,
	},
	-- Configuration for the actions floating preview window
	preview = {
		-- Width dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
		-- min_width and max_width can be a single value or a list of mixed integer/float types.
		-- max_width = {100, 0.8} means "the lesser of 100 columns or 80% of total"
		max_width = 0.9,
		-- min_width = {40, 0.4} means "the greater of 40 columns or 40% of total"
		min_width = { 40, 0.4 },
		-- optionally define an integer/float for the exact width of the preview window
		width = nil,
		-- Height dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
		-- min_height and max_height can be a single value or a list of mixed integer/float types.
		-- max_height = {80, 0.9} means "the lesser of 80 columns or 90% of total"
		max_height = 0.9,
		-- min_height = {5, 0.1} means "the greater of 5 columns or 10% of total"
		min_height = { 5, 0.1 },
		-- optionally define an integer/float for the exact height of the preview window
		height = nil,
		border = "rounded",
		win_options = {
			winblend = 0,
		},
		-- Whether the preview window is automatically updated when the cursor is moved
		update_on_cursor_moved = true,
	},
	-- Configuration for the floating progress window
	progress = {
		max_width = 0.9,
		min_width = { 40, 0.4 },
		width = nil,
		max_height = { 10, 0.9 },
		min_height = { 5, 0.1 },
		height = nil,
		border = "rounded",
		minimized_border = "none",
		win_options = {
			winblend = 0,
		},
	},
	-- Configuration for the floating SSH window
	ssh = {
		border = "rounded",
	},
	-- Configuration for the floating keymaps help window
	keymaps_help = {
		border = "rounded",
	},
})

-- UndoTree git config
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

vim.o.undofile = true
vim.o.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.g.undotree_WindowLayout = 2

-- Copilot config
-- Default disabled
vim.g.copilot_enabled = 0

vim.keymap.set('n', '<leader>ce', ':Copilot enable<CR>', { desc = 'Enable Copilot' })
vim.keymap.set('n', '<leader>cr', ':Copilot disable<CR>', { desc = 'Disable Copilot' })

vim.keymap.set('i', '<leader><leader>', 'copilot#Accept("\\<CR>")', {
  expr = true,
  replace_keycodes = false
})

vim.keymap.set('n', '<leader><Tab>', 'copilot#Accept("\\<CR>")', {
  expr = true,
  replace_keycodes = false
})

-- Old config stuff
vim.g.mapleader = " "

-- Telescope 

vim.keymap.set('n', '<leader>cf', function ()
	require('telescope.builtin').live_grep()	
end)

vim.keymap.set('n', '<leader>cd', function ()
	require('telescope.builtin').find_files()
end)

vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

vim.opt.relativenumber = true
vim.opt.scrolloff = 30
vim.opt.cursorline = true
vim.opt.inccommand = 'split'
vim.opt.timeoutlen = 300
vim.opt.updatetime = 250
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.number = true
vim.g.have_nerd_font = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 4
vim.opt.number = true

-- vim.opt.clipboard = "unnamedplus"
-- Lua function to search for .venv/scripts/python.exe and set Neovim's Python interpreter
local function set_python_interpreter()
    local current_dir = vim.fn.getcwd()  -- Get the current working directory
    local path_separator = package.config:sub(1,1) -- Get path separator based on OS

    -- Function to join paths
    local function join_paths(...)
        local args = {...}
        return table.concat(args, path_separator)
    end

    -- Traverse up the directory tree to find .venv
    while current_dir do
        local python_path = join_paths(current_dir, ".venv", "Scripts", "python.exe")

        -- Check if the Python executable exists
        if vim.fn.filereadable(python_path) == 1 then
            vim.g.python3_host_prog = python_path
            print("Neovim Python interpreter set to: " .. python_path)
            return
        end

        -- Move to the parent directory
        local parent_dir = vim.fn.fnamemodify(current_dir, ":h")
        if parent_dir == current_dir then
            break  -- Reached the root directory
        end
        current_dir = parent_dir
    end

    -- If no .venv is found, print a message
    print("No .venv found; using system Python interpreter")
end

