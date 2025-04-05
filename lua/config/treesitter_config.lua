
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "yaml", "markdown", "python", "lua", "json", "bash", "html", "css", "javascript", "typescript" },
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
}

