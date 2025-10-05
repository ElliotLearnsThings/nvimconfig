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


--require("nightfox").setup({
	--options = {
		--colorblind = {
			--enable = false,
			---- simulate_only = true,
			--severity = {
				---- protan = 1,
				---- deutan = 1,
				---- tritan = 1,
			--}
		--},
		--transparent = true,
		--terminal_colors = true,
		--styles = {               -- Style to be applied to different syntax groups
			--comments = "italic",     -- Value is any valid attr-list value `:help attr-list`
			--conditionals = "italic",
			--constants = "underdotted",
			--functions = "bold",
			--keywords = "italic",
			--numbers = "italic",
			--operators = "italic",
			--strings = "italic",
			--types = "bold",
			--variables = "NONE",
		--},
	--},
--})

local colors = {
	-- "rose-pine-main",
	"gruvbox",
	-- "nightfox",
	-- "tokyonight-night",
	-- "tokyonight-moon",
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


