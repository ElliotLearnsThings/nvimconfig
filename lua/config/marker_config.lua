
-- Map to set marks (waits for next character)
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

-- Map to jump to marks (waits for next character)
vim.keymap.set('n', '<leader>m', function()
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
