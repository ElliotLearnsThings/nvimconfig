local M = {}

M.basedpyright_settings = {
    root_dir = function(fname)
        -- This logic is fine to keep, ensuring the LSP correctly identifies the project root
        return vim.fn.getcwd()
    end,
    capabilities = capabilities,
    filetypes = { "python" },
    -- basedpyright has its own settings, distinct from pylsp.
    -- These are configured under 'settings.python' (following Pyright's convention)
    -- and directly under the root for `report` issues.
    settings = {
        python = {
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
                    "**/.venv",
                    "**/venv",
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

return M
