require("config.lazy")
require("config.undotree_config")
require("config.neogit_config")
require("config.git_signs_config")
require("config.lsp_config")
require("config.treesitter_config")
require("config.colors_config")
require("config.none_ls_config")
require("config.window_config")
require("config.oil_config")
require("config.marker_config")
require("config.buf_switch_2")
require("config.toggleterm_config")
require("config.change_variable_config")
require("config.render_markdown_config")

vim.opt.clipboard:append { 'unnamedplus' }
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.numberwidth = 2
vim.opt.signcolumn = "yes"
vim.opt.linespace = 10
vim.opt.scrolloff = 20
vim.opt.cursorline = false
vim.opt.inccommand = 'split'
vim.opt.timeoutlen = 300
vim.opt.updatetime = 250
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.number = true
vim.opt.background = 'dark'
vim.g.have_nerd_font = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 4
vim.opt.showtabline = 1
vim.opt.shortmess:append "I"
vim.g.mapleader = " "
vim.opt.guicursor = ""

vim.keymap.set("n", "<C-s>", "<CMD>w!<CR>")
vim.keymap.set("n", "<C-q>", "<CMD>wqa!<CR>")
vim.keymap.set("n", "<C-j>", "<C-d>")
vim.keymap.set("n", "<C-k>", "<C-u>")
vim.keymap.set('n', '<C-x>', '<C-v>',
	{ noremap = true, desc = "Visual block mode" }
)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev,
	{ desc = 'Go to previous [D]iagnostic message' }
)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next,
	{ desc = 'Go to next [D]iagnostic message' }
)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist,
	{ desc = 'Open diagnostic [Q]uickfix list' }
)
vim.keymap.set('n', '<leader>ff', vim.lsp.buf.format,
	{ desc = 'Format the current buffer with the lsp formatter' }
)
vim.keymap.set('n', '<leader>e',
	function() require('telescope.builtin').diagnostics() end
)
vim.keymap.set('n', '<leader>cc',
	function() require('telescope.builtin').live_grep() end
)
vim.keymap.set('n', '<leader>cr',
	function() require('telescope.builtin').grep_string() end
)
vim.keymap.set('n', '<leader>cs',
	function() require('telescope.builtin').spell_suggest() end
)
vim.keymap.set('n', '<leader>cd',
	function() require('telescope.builtin').find_files() end
)

-- Toggle diagnostic visibility
vim.keymap.set('n', '<leader>td', function()
	local diagnostics_visible = vim.diagnostic.is_disabled()
	if diagnostics_visible then
		vim.diagnostic.enable()
		vim.notify("Diagnostics enabled", vim.log.levels.INFO)
	else
		vim.diagnostic.disable()
		vim.notify("Diagnostics disabled", vim.log.levels.INFO)
	end
end, { desc = "Toggle diagnostic visibility" })


-- vim.cmd("syntax off")
