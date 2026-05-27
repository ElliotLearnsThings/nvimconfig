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
--
--#region
-- Oasis.nvim
-- Styles: "night", "midnight", "abyss", "starlight", "desert", "sol", "canyon", "dune", "cactus", "mirage", "lagoon", "twilight", "rose"
require("oasis").setup({
  style = "sol",                     -- Primary style, the default used when colorscheme is set to "oasis"
  dark_style = "abyss",                     -- Applies to primary style only: Overrides dark mode with another theme (e.g., "abyss")
  light_style = "starlight",                    -- Applies to primary style only: Overrides light mode with another theme (e.g., "dune")
  light_intensity = 2,                  -- Light background intensity (1-5): 1=subtle, 5=saturated
  use_legacy_comments = false,          -- For "desert" style only, uses the loud skyblue comment color from desert.vim for a more retro experience
  themed_syntax = true,                 -- Uses the theme's primary color for statements/keywords. Set to false for the classic yellow syntax from desert.vim for a more retro experience

  -- Text styling - toggle individual styles
  styles = {
    bold = true,                        -- Enable bold text (keywords, functions, etc.)
    italic = true,                      -- Enable italics (comments, certain keywords)
    underline = true,                   -- Enable underlined text (matching words)
    undercurl = true,                   -- Enable undercurl for diagnostics/spelling
    strikethrough = true,               -- Enable strikethrough text (deprecations)
  },

  -- Display options
  transparent = false,                  -- Set to true for transparent backgrounds (bye-bye theme backgrounds)
  terminal_colors = true,               -- Apply Oasis colors to Neovim's built-in terminal

  -- Contrast controls (WCAG: AA = 4.5, AAA = 7.0)
  contrast = {
    -- Note: Light themes obey the targets below. All dark themes target 7.0 by default with only a couple of exceptions that dip to 6.5.
    min_ratio = 4.5,                    -- Clamp 4.5–7.0; target contrast for syntax/terminal colors. Increase for more contrast, decrease for more pop.
    force_aaa = false,                  -- When true, forces AAA (7.0) wherever possible; as a result some colors will appear muddy (bye bye non-primary colors).
  },

  palette_overrides = {},               -- Override colors in specific palettes
  highlight_overrides = {},             -- Override specific highlight groups

  -- Plugin integrations
  integrations = {
    default_enabled = true,             -- Default behavior: true = enable all, false = disable all
    -- For each plugin: nil = use default_enabled, true = enable, false = disable
    plugins = {
      fzf_lua = nil,
      gitsigns = true,
      lazy = nil,
      mini = nil,
      render_markdown = nil,
      snacks = nil,
      which_key = nil,
    },
  },
})


require("catppuccin").setup({
    flavour = "latte",
    color_overrides = {
        latte = {
            base = "#FEC8CD",   -- Soft pastel pink background
            mantle = "#FBF4B6", -- Slightly deeper pink for sidebars/NvimTree
            crust = "#B4E9FF",  -- Pink for borders and floating windows
        },
    },
})

local colors = {
	-- "rose-pine-main",
	-- "gruvbox",
	"oasis",
	-- "catppuccin",
	-- "nightfox",
	-- "tokyonight-night",
	-- "tokyonight-moon",
}

vim.api.nvim_create_user_command("Dark", function()
	local bg = vim.o.background
	if bg == "light" then
		vim.o.background = 'dark'
	else
		vim.o.background = 'light'
	end
end, {})

vim.keymap.set(
"n", "<leader>dc", function ()
	vim.cmd("Dark")
end
)

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

if #colors ~= 0 then
	vim.cmd("colorscheme " .. colors[get_random_index(colors)])
end

vim.keymap.set(
"n", "<leader>cl", function ()
	vim.cmd("colorscheme " .. colors[get_random_index(colors)])
end
)

vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    vim.treesitter.stop()
  end,
})
