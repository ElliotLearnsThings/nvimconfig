
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "yaml", "markdown", "markdown_inline", "latex", "python", "lua", "json", "bash", "html", "css", "javascript", "typescript", "go", "rust" },
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
}

-- vim.api.nvim_set_hl(0, '@lsp.type.parameter',
	-- { fg = '#f67689', italic = true }
-- )
-- vim.api.nvim_set_hl(0, 'LineNrAbove',
	-- { fg = '#51C3BC', bold = true }
-- )
-- vim.api.nvim_set_hl(0, 'LineNr',
	-- { fg = 'white', bold = true }
--)
--vim.api.nvim_set_hl(0, 'LineNrBelow',
	--{ fg = '#aD9e30', bold = true }
----------------)
