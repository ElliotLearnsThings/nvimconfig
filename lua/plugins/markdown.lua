-- Markdown + math stack.
--
--   render-markdown.nvim  in-buffer rendering (headings, code, tables, callouts)
--                         and LaTeX -> unicode via `latex2text` (pipx install pylatexenc)
--   nabla.nvim            on-demand 2D ASCII rendering of the formula under the cursor
--   markdown-preview.nvim live browser preview with KaTeX for real typeset math
--   cmp-latex-symbols     `\alpha` -> α completion inside markdown
--
-- Buffer-local options and keymaps live in after/ftplugin/markdown.lua.

return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown", "Avante" },
		dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {
			file_types = { "markdown", "Avante" },
			-- Keep rendering while moving around in normal/visual, drop it in insert
			-- so the raw source is editable on the line being typed.
			render_modes = { "n", "v", "V", "\22", "c", "t" },
			anti_conceal = { enabled = true },
			latex = {
				enabled = true,
				converter = { "utftex", "latex2text" },
				inline = true,
				block = true,
				highlight = "RenderMarkdownMath",
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
}
