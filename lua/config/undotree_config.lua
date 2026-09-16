local undotree = require('undotree')

undotree.setup({
  float_diff = true,  -- using float window previews diff, set this `true` will disable layout option
  layout = "left_bottom", -- "left_bottom", "left_left_bottom"
  position = "left", -- "right", "bottom"
  ignore_filetype = {
    'undotree',
    'undotreeDiff',
    'qf',
  },
  window = {
    winblend = 30,
    border = "rounded", -- The string values are the same as those described in 'winborder'.
  },
  -- New-style `[action] = lhs` mapping (the old `[lhs] = action` form is deprecated).
  keymaps = {
    move_next = "j",
    move_prev = "k",
    move2parent = "gj",
    move_change_next = "J",
    move_change_prev = "K",
    action_enter = "<cr>",
    enter_diffbuf = "p",
    quit = "q",
  },
})

vim.keymap.set('n', '<leader>u', require('undotree').toggle, { noremap = true, silent = true })
vim.g.undotree_WindowLayout = 2
vim.o.undofile = true
