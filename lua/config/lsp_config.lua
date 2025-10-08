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

local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- Set on_attach and capabilities for all language servers

-- PYTHON --

vim.lsp.config['basedpyright'] = {
    capabilities = capabilities,
    filetypes = { "python" },
    -- basedpyright has its own settings, distinct from pylsp.
    -- These are configured under 'settings.python' (following Pyright's convention)
    -- and directly under the root for `report` issues.
    settings = {
			python = {
				venvPath = ".",   -- folder that contains the env
				venv = ".venv",
            analysis = {
                -- General analysis settings
                diagnosticMode = "workspace", -- 'workspace' or 'openFilesOnly'
                autoSearchPaths = true,
                use="basedpyright", -- Explicitly tell clients it's basedpyright (though not always strictly necessary for lspconfig)

                -- Type Checking Settings (equivalent to some pylsp_mypy behavior)
                typeCheckingMode = "strict", -- 'off', 'basic', or 'strict' (recommend 'basic' or 'strict' for better checks)
                reportGeneralTypeIssues = true,
                reportMissingTypeStubs = false, -- Set to true if you want warnings for missing type stubs
                reportMissingImports = true,
                reportUnusedImport = true,
                reportUnusedVariable = true,
                reportConstantRedefinition = true,
                reportPropertyTypeMismatch = true,
                reportCallIncompatible = true,
                reportArgumentTypeMismatch = true,
                reportUndefinedVariable = true,
                reportUndefinedFunction = true,
                reportUndefinedMember = true,
                reportUnreachable = true, -- basedpyright-specific for unreachable code
                reportAny = true, -- basedpyright-specific to flag 'Any' usage
                reportUntypedFunctionDecorator = false, -- Can be noisy, enable if you need
                reportUntypedBaseClass = false,
                reportInvalidTypeVarUse = true,
                reportFunctionMemberIncompatible = true,
                reportAttributeAccessIssue = true,
                reportImplicitStringConcatenation = true,

                -- Exclude/Ignore paths (CRUCIAL for performance)
                -- Add any directories you want basedpyright to ignore
                exclude = {
                    "**/node_modules",
                    "**/__pycache__",
                    "**/.git",
                    "**/.mypy_cache",
                    "**/build",
                    "**/dist",
                    -- Add your virtual environment path if it's inside your project
                    -- e.g., if your venv is at `my_project/.venv`, add ".venv"
                },
                -- Ignore specific files or patterns
                ignore = {
                    -- "my_project/some_legacy_file.py",
                    -- "**/third_party_lib/*.py",
                },
            },
            -- You can also configure specific `ruff` or `black` settings here if you use them with `basedpyright`.
            -- Example for Ruff (if basedpyright integrates with it directly, which it often does):
            -- linting = {
            --    enabled = true,
            --    lintOnSave = true,
            --    pylintEnabled = false,
            --    flake8Enabled = false,
            --    mypyEnabled = false, -- Disable if you prefer basedpyright's native type checking
            --    banditEnabled = false,
            --    ruffEnabled = true,
            --    ruffArgs = { "--fix", "--select", "E,F,W", "--ignore", "E501,E305,E303,E302" }, -- Example Ruff args
            -- }
        },
    },
}

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


