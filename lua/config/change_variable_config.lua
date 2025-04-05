local M = {}

function M.change_variable(input)
	-- Get the current word under the cursor
	-- Run %S/{word}/input/g

	local current_word = vim.fn.expand("<cword>")

	vim.cmd('%S/' .. current_word .. '/' .. input .. '/g')
end

function M.run_command()
	local input = vim.fn.input("Rename variable to: ")
	if input ~= "" then
		M.change_variable(input)
	else
		print("No input provided.")
	end
end

function M.setup(opts)
	local keymap = opts.keymap or "<leader>cv"

	-- Set up the command
	vim.api.nvim_create_user_command("ChangeVariable", function()
		M.run_command()
	end, { nargs = 0 })

	-- Set up the key mapping
	if vim.fn.has("nvim-0.9") == 1 then
		vim.keymap.set("n", keymap, ":ChangeVariable<CR>", { noremap = true, silent = true })
	else
		vim.keymap.set("n", keymap, ":ChangeVariable<CR>", { noremap = true, silent = true })
	end
end

return M
