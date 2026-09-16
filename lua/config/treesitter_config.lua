-- nvim-treesitter `main` branch: the old `configs` module is gone and
-- highlighting is started by Neovim's own ftplugins, so only the parser
-- list remains. Neovim bundles markdown/markdown_inline/lua/c/vim/query.
require('nvim-treesitter').install({
  "yaml", "markdown", "markdown_inline", "python", "lua", "json", "bash",
  "html", "css", "javascript", "typescript", "go", "rust", "latex",
})
