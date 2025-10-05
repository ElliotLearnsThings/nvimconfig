vim.keymap.set('n', '<leader>es','<CMD>Telescope diagnostics<CR>', { desc = "Show diagnostics in floating window" })
vim.keymap.set('n', '<leader>ee','<CMD>Telescope<CR>', { desc = "Show diagnostics in floating window" })
vim.keymap.set('n', '<leader>er','<CMD>Telescope lsp_references<CR>', { desc = "Show diagnostics in floating window" })
vim.keymap.set('n', '<leader>ew','<CMD>Telescope lsp_implementations<CR>', { desc = "Show diagnostics in floating window" })
vim.keymap.set('n', '<leader>ed','<CMD>Telescope lsp_definitions<CR>', { desc = "Show diagnostics in floating window" })
vim.keymap.set('n', '<leader>eb', '<CMD>Telescope buffers<CR>', { desc = "Show diagnostics in floating window" })

local onAttach = function(client, bufnr)
	local bufopts = { noremap=true, silent=true, buffer=bufnr }

	vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
	vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
	vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
	vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)

	vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
	vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
	vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
	vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)

	-- Enable completion triggered by <c-x><c-o>
	vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

	-- Mappings.
	-- See `:help vim.diagnostic.*` for documentation on any of the below functions
	local opts = { noremap=true, silent=true }
	vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
	vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
	vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
	vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)

end

local basedpyright_settings = require('config.settings.basedpyright_settings').basedpyright_settings

local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- Set on_attach and capabilities for all language servers

-- PYTHON --

vim.lsp.config['basedpyright'] = basedpyright_settings

-- TYPESCRIPT --

vim.lsp.config['vtsls'] = {
	capabilities = capabilities, -- Ensure capabilities are defined elsewhere
	filetypes = {
		"typescript",
		"typescriptreact",
		"javascript",
		"javascriptreact",
		"tailwindcss"
	},
	-- Add supported file types
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
		onAttach(client, bufnr) -- Call the common on_attach function
	end,
}

-- JAVA --

vim.lsp.config['jdtls'] = {
	-- This command must be customized to your system, as JDTLS is not typically in the PATH.
	-- If using mason.nvim, the command below should work out of the box.
	cmd = { "jdtls" },
	filetypes = { "java" },
	capabilities = capabilities,
	root_dir = function(fname)
		return lspconfig.util.root_pattern("pom.xml", "build.gradle", ".gradle", ".git")(fname) or lspconfig.util.find_git_ancestor(fname)
	end,
	settings = {
		-- Optional: Configure Java-specific settings here.
		-- For example, setting the Java home directory
		java = {
			home = "/usr/lib/jvm/java-17-openjdk", -- Replace with your JDK path
		},
		-- Optional: Enable/disable specific features.
		-- For example, to set compiler options
		extendedClientCapabilities = {
			classFileContentsSupport = true
		}
	},
	on_attach = function(client, bufnr)
		-- Enable autocompletion from JDTLS
		client.server_capabilities.completionProvider.triggerCharacters = { ".", "<", " " }
		-- Put any additional keymaps here
		onAttach(client, bufnr) -- Call the common on_attach function
	end,
}


