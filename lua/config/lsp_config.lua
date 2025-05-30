vim.keymap.set('n', '<leader>es','<CMD>Telescope diagnostics<CR>', { desc = "Show diagnostics in floating window" })
vim.keymap.set('n', '<leader>ee','<CMD>Telescope<CR>', { desc = "Show diagnostics in floating window" })
vim.keymap.set('n', '<leader>er','<CMD>Telescope lsp_references<CR>', { desc = "Show diagnostics in floating window" })
vim.keymap.set('n', '<leader>ew','<CMD>Telescope lsp_implementations<CR>', { desc = "Show diagnostics in floating window" })
vim.keymap.set('n', '<leader>ed','<CMD>Telescope lsp_definitions<CR>', { desc = "Show diagnostics in floating window" })
vim.keymap.set('n', '<leader>eb', '<CMD>Telescope buffers<CR>', { desc = "Show diagnostics in floating window" })
