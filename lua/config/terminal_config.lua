local M = {}

-- Make a new tab with leader nt
M.new_tab = function()
	vim.cmd('tabnew')
end

return M
