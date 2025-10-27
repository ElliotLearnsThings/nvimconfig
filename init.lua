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

vim.opt.clipboard:append { 'unnamedplus' }
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.numberwidth = 2
vim.opt.signcolumn = "yes"
vim.opt.linespace = 10
vim.opt.scrolloff = 40
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
vim.opt.showtabline = 1
vim.opt.shortmess:append "I"
vim.g.mapleader = " "

vim.keymap.set("n", "<C-s>", "<CMD>w!<CR>")
vim.keymap.set("n", "<C-q>", "<CMD>wqa!<CR>")
vim.keymap.set("n", "<C-j>", "<C-d>")
vim.keymap.set("n", "<C-k>", "<C-u>")
vim.keymap.set('n', '<C-x>', '<C-v>', { noremap = true, desc = "Visual block mode" })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader>cf', function () require('telescope.builtin').live_grep() end)
vim.keymap.set('n', '<leader>cd', function () require('telescope.builtin').find_files() end)
vim.api.nvim_set_hl(0, '@lsp.type.parameter', {fg='#f67689', italic=true})
vim.api.nvim_set_hl(0, 'LineNrAbove', { fg='#81F3EC', bold=true })
vim.api.nvim_set_hl(0, 'LineNr', { fg='white', bold=true })
vim.api.nvim_set_hl(0, 'LineNrBelow', { fg='#dDbe60', bold=true })

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

