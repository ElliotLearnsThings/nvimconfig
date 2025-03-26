local M = {}

function M.set_tab(tab_number)
	vim.cmd('tabnext ' .. tab_number)
end

function M.remove_tab(tab_number)
	vim.cmd('tabclose ' .. tab_number)
end

return M
