local M = {}

require("copilot").setup({
	suggestion = {
		auto_trigger = true,
		debounce = 500,
		keymap = {
			accept = "<C-l>",
			prev = "<C-p>",
			next = "<C-n>",
		},
	}
})

vim.keymap.set('n', '<leader>ce', ':Copilot enable<CR>', { desc = 'Enable Copilot' })
vim.keymap.set('n', '<leader>cr', ':Copilot disable<CR>', { desc = 'Disable Copilot' })

vim.keymap.set('i', '<C-y>', 'copilot#Accept("\\<CR>")', {
  expr = true,
  replace_keycodes = false
})

-- what is the 

-- Copilot config
-- Default disabled
vim.g.copilot_enabled = 1

return M
