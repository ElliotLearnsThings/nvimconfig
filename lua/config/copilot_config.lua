local M = {}

vim.keymap.set('n', '<leader>ce', ':Copilot enable<CR>', { desc = 'Enable Copilot' })
vim.keymap.set('n', '<leader>cr', ':Copilot disable<CR>', { desc = 'Disable Copilot' })

vim.keymap.set('i', '<C-y>', 'copilot#Accept("\\<CR>")', {
  expr = true,
  replace_keycodes = false
})

vim.keymap.set('n', '<leader><Tab>', 'copilot#Accept("\\<CR>")', {
expr = true,
replace_keycodes = false
})

return M
