-- null ls for prettier
local null_ls = require("null-ls")

null_ls.setup({
	debug = false, -- or true for debugging
	sources = {
		-- Use either `prettier` or `prettierd`, whichever you prefer
		null_ls.builtins.formatting.prettierd.with({
			filetypes = {
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
				"json",
				"yaml",
				"html",
				"css",
				"markdown"
				-- etc.
			},
			-- extra_args = { "--print-width", "80" }, -- optional
		}),
	},
	on_attach = function(client, bufnr)
		-- Keymap to manually format
		if client.supports_method("textDocument/formatting") then
			vim.keymap.set("n", "<leader>f", function()
				vim.lsp.buf.format({ bufnr = bufnr })
			end, { buffer = bufnr, desc = "Format with null-ls" })
		end

		-- Auto-format on save
		local group = vim.api.nvim_create_augroup("lsp_format_on_save", { clear = false })
		vim.api.nvim_clear_autocmds({ buffer = bufnr, group = group })
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = bufnr,
			group = group,
			callback = function()
				vim.lsp.buf.format({ bufnr = bufnr }) -- or async = false/true
			end,
			desc = "Format on save with null-ls",
		})
	end,
})
