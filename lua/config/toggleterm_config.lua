require("toggleterm").setup{
	open_mapping = [[<c-\>]],
	direction = 'horizontal',
	float_opts = {
		border = 'curved',
	}
}

vim.keymap.set("n", "<leader>1", "<cmd>1ToggleTerm direction=float<CR>", { desc = "Toggle terminal 1" })
vim.keymap.set("n", "<leader>2", "<cmd>2ToggleTerm direction=float<CR>", { desc = "Toggle terminal 2" })
vim.keymap.set("n", "<leader>3", "<cmd>3ToggleTerm direction=float<CR>", { desc = "Toggle terminal 3" })
