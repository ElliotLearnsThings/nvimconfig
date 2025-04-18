-- Baseic config
vim.keymap.set('n', '<C-[>', '<C-w>h', { noremap = true, silent = true })
vim.keymap.set('n', '<C-j>', '<C-w>j', { noremap = true, silent = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { noremap = true, silent = true })
vim.keymap.set('n', '<C-]>', '<C-w>l', { noremap = true, silent = true })

-- Window splitting (right and down)
vim.keymap.set('n', '<leader>wd', '<C-w>s', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>wf', '<C-w>v', { noremap = true, silent = true })

vim.keymap.set('n', '<C-w>]', '<C-w>L', { noremap = true, silent = true })
vim.keymap.set('n', '<C-w>[', '<C-w>H', { noremap = true, silent = true })
vim.keymap.set('n', '<C-w>j', '<C-w>J', { noremap = true, silent = true })
vim.keymap.set('n', '<C-w>k', '<C-w>K', { noremap = true, silent = true })

-- Window resizing
vim.keymap.set('n', '<leader>wh', '<C-w><', { noremap = true, silent = true, desc = "Decrease width" })
vim.keymap.set('n', '<leader>wl', '<C-w>>', { noremap = true, silent = true, desc = "Increase width" })
vim.keymap.set('n', '<leader>wk', '<C-w>+', { noremap = true, silent = true, desc = "Increase height" })
vim.keymap.set('n', '<leader>wj', '<C-w>-', { noremap = true, silent = true, desc = "Decrease height" })

vim.cmd([[highlight WinSeparator guifg=#4e545c guibg=None]])

