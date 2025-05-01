vim.o.termguicolors = true  -- Enable true color support


-- Default options:
require("gruvbox").setup({
  terminal_colors = true, -- add neovim terminal colors
  undercurl = true,
  underline = true,
  bold = true,
  italic = {
    strings = true,
    emphasis = true,
    comments = true,
    operators = false,
    folds = true,
  },
  strikethrough = true,
  invert_selection = false,
  invert_signs = false,
  invert_tabline = false,
  invert_intend_guides = false,
  inverse = false, -- invert background for search, diffs, statuslines and errors
  contrast = "hard", -- can be "hard", "soft" or empty string
  palette_overrides = {},
  overrides = {},
  dim_inactive = false,
  transparent_mode = true,
})


require("nightfox").setup({
	options = {
		colorblind = {
			enable = false,
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

local colors = {
	"rose-pine-main",
	"gruvbox",
	"nightfox",
	"tokyonight-night",
	"tokyonight-moon",
}

local init = false

local function get_random_index(table)
	local rnd = math.floor(math.random() * (#table)) + 1
	if init then
		vim.print(vim.inspect{color = table[rnd]})
	else
		init = true
	end
	return rnd
end

vim.cmd("colorscheme " .. colors[get_random_index(colors)])

vim.keymap.set(
"n", "<leader>cc", function ()
	vim.cmd("colorscheme " .. colors[get_random_index(colors)])
end
)


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
	enable_tailwind = true,

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
