-- Markdown + math stack.
--
--   snacks.nvim (image)   LaTeX typeset by tectonic and drawn as images, inline and
--                         block, and embedded images; blocks and images centered.
--                         Needs the kitty graphics protocol (ghostty/kitty), also
--                         through tmux. Tweaks in lua/config/markdown_math.lua and
--                         lua/config/markdown_images.lua.
--   render-markdown.nvim  in-buffer rendering (headings, code, tables, callouts)
--                         and, where snacks can't draw images, LaTeX -> unicode.
--                         Converters are tried in order:
--                           utftex      2D layout (yay -S libtexprintf)
--                           latex2text  flat fallback (uv tool install pylatexenc)
--   nabla.nvim            on-demand 2D ASCII rendering of the formula under the cursor
--   markdown-preview.nvim live browser preview with KaTeX for real typeset math
--   cmp-latex-symbols     `\alpha` -> α completion inside markdown
--   cmp-spell             spelling suggestions for every 'spelllang' (English + Swedish)
--
-- Buffer-local options and keymaps live in after/ftplugin/markdown.lua.

return {
	{
		-- snacks wants to load early; only the image module is enabled.
		"folke/snacks.nvim",
		lazy = false,
		priority = 1000,
		---@type snacks.Config
		opts = {
			image = {
				enabled = true,
				doc = { inline = true },
			},
		},
		config = function(_, opts)
			local markdown_math = require("config.markdown_math")
			require("snacks").setup(vim.tbl_deep_extend("force", opts, { image = markdown_math.opts }))
			-- First, so a revealed math block, which markdown_math draws itself, is
			-- centered too.
			require("config.markdown_images").setup()
			markdown_math.setup()
		end,
	},

	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown", "Avante" },
		dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {
			file_types = { "markdown", "Avante" },
			-- Keep rendering while moving around in normal/visual, drop it in insert
			-- so headings, bullets and tables show their raw source while typing.
			render_modes = { "n", "v", "V", "\22", "c", "t" },
			anti_conceal = { enabled = true },
			overrides = {
				filetype = {
					-- Keep the cursor line concealed, also in insert mode, so only the formula
					-- under the cursor shows its source (config/markdown_math.lua).
					markdown = {
						win_options = {
							conceallevel = { default = 2, rendered = 3 },
							concealcursor = { default = "nvic", rendered = "nvic" },
						},
					},
				},
			},
			latex = {
				enabled = true,
				converter = { "utftex", "latex2text" },
				inline = true,
				block = true,
				highlight = "Normal", -- body text color, like the snacks images
				position = "center",
			},
			heading = {
				sign = false,
				icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
				position = "inline",
				width = "block",
				min_width = 60,
				border = true,
			},
			code = {
				sign = false,
				width = "block",
				min_width = 60,
				left_pad = 1,
				right_pad = 1,
				border = "thin",
			},
			bullet = { icons = { "●", "○", "◆", "◇" } },
			checkbox = {
				unchecked = { icon = "󰄱 " },
				checked = { icon = "󰱒 " },
				custom = {
					todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
					important = { raw = "[!]", rendered = " ", highlight = "RenderMarkdownError" },
				},
			},
			pipe_table = { preset = "round", cell = "padded" },
			link = { wiki = { icon = "󱗖 " } },
			indent = { enabled = false },
		},
		config = function(_, opts)
			-- Unicode math only where snacks can't typeset it, so the two never overlap.
			opts.latex.enabled = not (_G.Snacks and Snacks.image.supports_terminal())
			require("render-markdown").setup(opts)
		end,
	},

	{
		-- Pure-Lua LaTeX -> 2D ASCII math (fractions, roots, sums laid out vertically).
		"jbyuki/nabla.nvim",
		ft = "markdown",
	},

	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = "markdown",
		-- mkdp#util#install isn't autoloaded at build time under lazy-loading,
		-- so build the server from the bundled app instead (node is on PATH).
		build = "cd app && npm install --no-audit --no-fund",
		init = function()
			vim.g.mkdp_auto_close = 1
			vim.g.mkdp_refresh_slow = 0
			vim.g.mkdp_theme = "dark"
			vim.g.mkdp_page_title = "${name}"
			vim.g.mkdp_preview_options = {
				katex = { throwOnError = false, macros = {} },
				disable_sync_scroll = 0,
				sync_scroll_type = "middle",
			}
		end,
	},

	{
		"kdheepak/cmp-latex-symbols",
		ft = "markdown",
		dependencies = { "hrsh7th/nvim-cmp" },
	},

	{
		-- Suggests from vim.fn.spellsuggest(), so from all languages in 'spelllang'.
		"f3fora/cmp-spell",
		ft = "markdown",
		dependencies = { "hrsh7th/nvim-cmp" },
	},
}
