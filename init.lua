require("config.lazy")
require("config.dap_config")

require("config.buf_switch_2").setup({
	debug = false,
})

-- Renam variable config
require("config.change_variable_config").setup({
	keymap = "<leader>cv"
})

-- Remap dvorak config
require("config.dvorak").setup({
  keymap = "<leader>00"
})

-- macro config
require("config.macro_config")

-- codecompanion setup

-- Git signs config

require("config.git_signs_config")

-- Lsp config
require("config.lsp_config")

-- vim.env.RUST_ANALYZER_MEMORY_LIMIT = "2048"  -- Set memory limit in MB

-- Terminal 
-- Remove relative line numbers in terminal
local terminal = {}

-- Make a new tab with leader nt
terminal.new_tab = function()
	vim.cmd('tabnew')
end

vim.cmd([[au TermOpen term://* setlocal nonumber norelativenumber]])

vim.keymap.set("n", "<leader>nt", terminal.new_tab, { desc = "Open a new terminal tab" })
vim.keymap.set("n", "<leader>st", function()
  local height = 4
  vim.cmd("botright " .. height .. "split term://zsh")
  vim.cmd("startinsert")
end, { desc = "Open a small terminal at bottom" })

-- Copilot 
require("config.copilot_config")

-- hardtime
-- require("config.hardtime_config")


-- Treesitter
require("config.treesitter_config")

-- CC config
-- require("config.cc_config")

-- Lua line
--- require("config.lua_line_config")

--- None ls
require("config.none_ls_config")

-- Colors
require("config.colors_config")


--- Neogit config
require("config.neogit_config")

-- window config
require("config.window_config")

vim.opt.clipboard:append { 'unnamedplus' }
--vim.opt.clipboard = ""

-- Harpoon config

-- require("config.harpoon_config")

--- Oil config
require("config.oil_config")

-- UndoTree git config
-- vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
-- vim.g.undotree_WindowLayout = 2

vim.o.undofile = true

-- Function to replace occurrences of the first string with the second string in a given range
function ReplaceInRange(from, to)
	-- Construct the command using the given inputs
	local command = string.format(":'<,'>s/%s/%s/g", from, to)
	-- Execute the command in Vim
	vim.cmd(command)
end

-- Bind function to a custom command that works in visual mode
vim.api.nvim_exec([[
command! -range -nargs=+ ReplaceInRange lua ReplaceInRange(<f-args>)
]], false)


vim.keymap.set('n', '<leader>ce', ':Copilot enable<CR>', { desc = 'Enable Copilot' })
vim.keymap.set('n', '<leader>cr', ':Copilot disable<CR>', { desc = 'Disable Copilot' })

vim.keymap.set('n', '<leader><Tab>', 'copilot#Accept("\\<CR>")', {
	expr = true,
	replace_keycodes = false
})


-- Telescope 

vim.keymap.set('n', '<leader>cf', function ()
	require('telescope.builtin').live_grep()	
end)

vim.keymap.set('n', '<leader>cd', function ()
	require('telescope.builtin').find_files()
end)

vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

vim.keymap.set('n', '<leader>[a', "<CMD>bprev<CR>", { desc = 'Go buffer prev' })
vim.keymap.set('n', '<leader>]a', "<CMD>bnext<CR>", { desc = 'Go buffer next' })

vim.opt.relativenumber = true
vim.opt.scrolloff = 30
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
vim.opt.number = true
vim.opt.showtabline = 1

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


-- Function to set a mark with <C-g> in normal mode, or go to mark if mark is set
vim.keymap.set('n', 'm', '<Nop>', { noremap = true })
vim.keymap.set('n', '`', '<Nop>', { noremap = true })



-- Map <C-g> to set marks (waits for next character)
vim.keymap.set('n', '<leader>s', function()
	local mark_val = vim.fn.getchar()
	if mark_val == 0 then
		return
	end

	-- Handle control keys (ASCII 1-26)
	local mark
	if mark_val >= 1 and mark_val <= 26 then
		mark = string.char(mark_val + 96) -- Convert to lowercase letter
	else
		mark = string.char(mark_val)
	end

	local line = vim.fn.line('.')
	local col = vim.fn.col('.')
	vim.fn.setpos("'" .. mark, {0, line, col, 0})
	print("Mark '" .. mark .. "' set")
end, { noremap = true })

-- Map <C-h> to jump to marks (waits for next character)
vim.keymap.set('n', '<leader>h', function()
	local mark_val = vim.fn.getchar()
	if mark_val == 0 then
		return
	end

	-- Handle control keys (ASCII 1-26)
	local mark
	if mark_val >= 1 and mark_val <= 26 then
		mark = string.char(mark_val + 96) -- Convert to lowercase letter
	else
		mark = string.char(mark_val)
	end

	local pos = vim.fn.getpos("'" .. mark)
	if pos[2] == 0 then
		print("Mark '" .. mark .. "' not set")
		return
	end
	vim.cmd("normal! '" .. mark)
end, { noremap = true })

vim.keymap.set('n', '<C-x>', '<C-v>', { noremap = true, desc = "Visual block mode" })

-- Old config stuff
vim.g.mapleader = " "

-- Swap "c" with "d" in normal mode
-- vim.keymap.set('n', 'd', 'c', {noremap = true})
-- vim.keymap.set('n', 'c', 'd', {noremap = true})
-- vim.keymap.set('v', 'd', 'c', {noremap = true})
-- vim.keymap.set('v', 'c', 'd', {noremap = true})
-- vim.keymap.set('n', 'dd', 'cc', {noremap = true})
-- vim.keymap.set('n', 'cc', 'dd', {noremap = true})
-- vim.keymap.set('n', 'D', 'C', {noremap = true})
-- vim.keymap.set('n', 'C', 'D', {noremap = true})
-- vim.keymap.set('v', 'D', 'C', {noremap = true})
-- vim.keymap.set('v', 'C', 'D', {noremap = true})
--
-- tmux config
--
-- line colors
function LineNumberColors()
	vim.api.nvim_set_hl(0, 'LineNrAbove', { fg='#51B3EC', bold=true })
	vim.api.nvim_set_hl(0, 'LineNr', { fg='white', bold=true })
	vim.api.nvim_set_hl(0, 'LineNrBelow', { fg='#FB508F', bold=true })
end

LineNumberColors()

-- Tab config
local tab = require("config.tab_config")
vim.keymap.set("n", "<leader>f1", function() tab.set_tab(1) end, { desc = "Go to tab 1" })
vim.keymap.set("n", "<leader>f2", function() tab.set_tab(2) end, { desc = "Go to tab 2" })
vim.keymap.set("n", "<leader>f3", function() tab.set_tab(3) end, { desc = "Go to tab 3" })
vim.keymap.set("n", "<leader>f4", function() tab.set_tab(4) end, { desc = "Go to tab 4" })
vim.keymap.set("n", "<leader>f5", function() tab.set_tab(5) end, { desc = "Go to tab 5" })
vim.keymap.set("n", "<leader>f6", function() tab.set_tab(6) end, { desc = "Go to tab 6" })
vim.keymap.set("n", "<leader>f7", function() tab.set_tab(7) end, { desc = "Go to tab 7" })
vim.keymap.set("n", "<leader>f8", function() tab.set_tab(8) end, { desc = "Go to tab 8" })
vim.keymap.set("n", "<leader>f9", function() tab.set_tab(9) end, { desc = "Go to tab 9" })

vim.keymap.set("n", "<leader>r1", function() tab.remove_tab(1) end, { desc = "Remove tab 1" })
vim.keymap.set("n", "<leader>r2", function() tab.remove_tab(2) end, { desc = "Remove tab 2" })
vim.keymap.set("n", "<leader>r3", function() tab.remove_tab(3) end, { desc = "Remove tab 3" })
vim.keymap.set("n", "<leader>r4", function() tab.remove_tab(4) end, { desc = "Remove tab 4" })
vim.keymap.set("n", "<leader>r5", function() tab.remove_tab(5) end, { desc = "Remove tab 5" })
vim.keymap.set("n", "<leader>r6", function() tab.remove_tab(6) end, { desc = "Remove tab 6" })
vim.keymap.set("n", "<leader>r7", function() tab.remove_tab(7) end, { desc = "Remove tab 7" })
vim.keymap.set("n", "<leader>r8", function() tab.remove_tab(8) end, { desc = "Remove tab 8" })
vim.keymap.set("n", "<leader>r9", function() tab.remove_tab(9) end, { desc = "Remove tab 9" })

