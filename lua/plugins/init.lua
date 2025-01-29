require("lazy").setup({{"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"}})

return {
	{
		'github/copilot.vim',
	},
	{
		'neovim/nvim-lspconfig',
	},

	{
		"nvim-tree/nvim-web-devicons",
	},

	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate", -- optional
		config = function()
			require("mason").setup()
		end,
	},

	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "pyright" }, -- Adjust to your needs
				automatic_installation = true,
			})

			local lspconfig = require("lspconfig")
			local capabilities = require("cmp_nvim_lsp").default_capabilities() -- Optional: integrate with nvim-cmp

			lspconfig.ts_ls.setup({
				capabilities = capabilities, -- Ensure capabilities are defined elsewhere
				filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" }, -- Add supported file types
				settings = {
					completions = {
						completeFunctionCalls = true, -- Enable function call completions
					},
					javascript = {
						suggest = {
							autoImports = true,
						},
						format = {
							enable = true, -- Enable formatting for JavaScript
						},
					},
					typescript = {
						suggest = {
							autoImports = true,
						},
						format = {
							enable = true, -- Enable formatting for TypeScript
						},
					},
				},
				on_attach = function(client, bufnr)
					-- Disable tsserver formatting if you use a separate formatter like prettier
					client.server_capabilities.documentFormattingProvider = false
					client.server_capabilities.documentRangeFormattingProvider = false

					-- Keybindings for LSP functionality
					local opts = { noremap = true, silent = true }
					local keymap = vim.api.nvim_buf_set_keymap
					keymap(bufnr, "n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
					keymap(bufnr, "n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
					keymap(bufnr, "n", "gi", "<Cmd>lua vim.lsp.buf.implementation()<CR>", opts)
					keymap(bufnr, "n", "<leader>rn", "<Cmd>lua vim.lsp.buf.rename()<CR>", opts)
					keymap(bufnr, "n", "<leader>ca", "<Cmd>lua vim.lsp.buf.code_action()<CR>", opts)
				end,
			})

			-- Example: Lua language server
			lspconfig.lua_ls.setup({
				capabilities = capabilities,
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						diagnostics = { globals = { "vim" } },
						workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
					},
				},
			})

			lspconfig.basedpyright.setup({
				on_attach = function(client, bufnr)
					local buf_map = function(mode, lhs, rhs, opts)
						opts = opts or {}
						opts.buffer = bufnr
						vim.keymap.set(mode, lhs, rhs, opts)
					end

					-- Example keybindings for LSP
					buf_map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
					buf_map("n", "K", vim.lsp.buf.hover, { desc = "Hover info" })
				end,
			})
			lspconfig.gopls.setup({})

		end,
	},

	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
		},
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<Tab>"] = cmp.mapping.confirm({ select = true }),
				}),
				sources = {
					{ name = "nvim_lsp" },
					{ name = "buffer" },
					{ name = "path" },
				},
			})
		end,
	},


	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
	},
	{
		"nvim-telescope/telescope.nvim", tag = '0.1.8',
		branch = '0.1.x',
		dependencies = { 'nvim-lua/plenary.nvim' }
	},
	{
		'stevearc/oil.nvim',
		---@module 'oil'
		---@type oil.SetupOpts
		opts = {},
		-- Optional dependencies
		dependencies = { { "echasnovski/mini.icons", opts = {} } },
		-- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
	},
	'ThePrimeagen/harpoon',
	'mbbill/undotree',
	'tpope/vim-fugitive',
}
