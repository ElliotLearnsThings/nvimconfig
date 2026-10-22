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

local python_env = require("config.python_env")

vim.lsp.config['basedpyright'] = {
    capabilities = capabilities,
    filetypes = { "python" },
    -- uv keeps one `.venv` at the *workspace* root, so a member package's own
    -- pyproject.toml is the wrong project root: uv.lock (only ever written at the
    -- workspace root) and pyrightconfig.json take priority over it. Everything
    -- below this line is nvim-lspconfig's default list.
    root_markers = {
        { 'pyrightconfig.json', 'uv.lock' },
        'pyproject.toml',
        'setup.py',
        'setup.cfg',
        'requirements.txt',
        'Pipfile',
        '.git',
    },
    -- basedpyright resolves imports from `python.pythonPath` and ignores
    -- `python.venv` over the wire, so the interpreter is resolved per project
    -- root and injected below rather than pointed at with venvPath/venv.
    before_init = function(_, config)
        -- Mutated in place: vim.lsp.Client keeps a reference to this very table
        -- and answers workspace/configuration out of it, so replacing it here
        -- would leave the client holding the old settings.
        config.settings.python = config.settings.python or {}
        config.settings.python.pythonPath = python_env.resolve(config.root_dir)
    end,
    settings = {
			python = {
            -- NOTE: basedpyright reads `basedpyright.analysis` in preference to
            -- `python.analysis`, and nvim-lspconfig always supplies the former,
            -- so nothing in this block currently reaches the server. Rename the
            -- key to `basedpyright` to turn it on (expect a lot of new
            -- diagnostics: typeCheckingMode is strict and reportAny is true).
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
vim.lsp.config['emmet_ls'] = {
	capabilities = capabilities, -- Ensure capabilities are defined elsewhere
	filetypes = {
		"html"
	},
}

vim.lsp.config['tailwindcss'] = {
	capabilities = capabilities, -- Ensure capabilities are defined elsewhere
	filetypes = {
		"typescript",
		"typescriptreact",
		"javascript",
		"javascriptreact",
		"tailwindcss",
		"html"
	},
}

vim.lsp.config['vtsls'] = {
	capabilities = capabilities, -- Ensure capabilities are defined elsewhere
	filetypes = {
		"typescript",
		"typescriptreact",
		"javascript",
		"javascriptreact",
		"tailwindcss",
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

-- JULIA --

-- LanguageServer.jl lives in ~/.julia/environments/nvim-lspconfig, where
-- nvim-lspconfig's default cmd looks for it (not managed by mason).
-- Not a mason package, so mason-lspconfig won't enable it for us.
vim.lsp.config['julials'] = {
	capabilities = capabilities,
}
vim.lsp.enable('julials')

-- JAVA --

vim.lsp.config['jdtls'] = {
	-- This command must be customized to your system, as JDTLS is not typically in the PATH.
	-- If using mason.nvim, the command below should work out of the box.
	cmd = { "jdtls" },
	filetypes = { "java" },
	capabilities = capabilities,
	-- Not a root_dir function: vim.lsp.config calls it as (bufnr, on_dir), and an error
	-- there aborts the FileType autocmd and the :edit with it, so BufEnter never fires
	root_markers = { "pom.xml", "build.gradle", ".gradle", ".git" },
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


