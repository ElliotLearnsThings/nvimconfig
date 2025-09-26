require("lazy").setup({{"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"}})

local basedpyright_settings = {
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


function lspDefaultConfig ()
	require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "basedpyright", "jdtls", "rust_analyzer", "ts_ls" }, -- Adjust to your needs
				automatic_installation = true,
			})

			local capabilities = require("cmp_nvim_lsp").default_capabilities() -- Optional: integrate with nvim-cmp



			-- local PYTHON_PATH = PYTHON_PATH_FINDER.get_python_path_wrapper(vim.fn.getcwd(), false)
			vim.lsp.config["basedpyright"] = basedpyright_settings


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
				end,
			}

			vim.lsp.config['ts_ls'] = {
				capabilities = capabilities, -- Ensure capabilities are defined elsewhere
				filetypes = { 
					"typescript",
					"typescriptreact",
					"javascript",
					"javascriptreact",
					"emmet_ls",
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
				end,
			}

			vim.lsp.config["emmet_ls"] = {
				filetypes = {
					"html",
					"css",
					"scss",
					"javascriptreact",
					"typescriptreact",
					"svelte",
					"vue",
				},
			}

			vim.lsp.config['rust_analyzer'] = {
					capabilities = capabilities,
					filetypes = { "rust" },
						settings = {
							['rust-analyzer'] = {
								cargo = {
									loadOutDirsFromCheck = true,
									allFeatures = true,
									allTargets = true,
									buildScripts = {
										enable = true,
									},
								},
								procMacro = {
									enable = true,
								},
								checkOnSave = {
									allFeatures = true,
									allTargets = true,
									command = "clippy",
								},
								diagnostics = {
									enableExperimental = true,
								},
							}
						},
					}

			vim.lsp.config['tailwindcss'] = {
			 	capabilities = capabilities,
				filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" }, -- Add supported file types
			}

			-- Example: Lua language server
			vim.lsp.config['lua_ls'] = {
				capabilities = capabilities,
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						diagnostics = { globals = { "vim" } },
						workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
					},
				},
			}

			-- Enable all servers
			vim.lsp.enable(vim.tbl_keys(vim.lsp.config))

end
	



local function get_api_key()

	local api_key = require("config.api_key")
	-- vim.notify(api_key, vim.log.levels.INFO)
	return api_key
end

API_KEY = get_api_key()

PYTHON_PATH_FINDER = require("config.local_python_config")

return {

	{"olimorris/codecompanion.nvim"},
	{"rose-pine/neovim", as="rose-pine"},
	{"ellisonleao/gruvbox.nvim"},
	{
		"nvimtools/none-ls.nvim",
	},
	{
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {

		}
	},

	{
		"lewis6991/gitsigns.nvim",
	},

	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
	},

	{
		"rcarriga/nvim-dap-ui",
	},
	{
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
	{
		"nvim-neotest/nvim-nio",
	},
	{
		"mfussenegger/nvim-dap",
	},
	{
		"tpope/vim-abolish",
	},
	-- {
		-- "m4xshen/hardtime.nvim",
		-- dependencies = { "MunifTanjim/nui.nvim" },
		-- opts = {}
	-- },
	{
		"MunifTanjim/prettier.nvim",
	},
	-- {
		-- "phaazon/hop.nvim",
		-- branch = 'v2',
	-- },
	{
		'nvim-lualine/lualine.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons' }
	},
	{
		'brenoprata10/nvim-highlight-colors'
	},

	{
		"nvim-tree/nvim-web-devicons",
	},

	-- In your plugins file
	{
		"kylechui/nvim-surround",
		version = "*", -- Use for stability; omit to use `main` branch for the latest features
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({
				-- Configuration is optional, defaults are great
			})
		end,
	},

	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate", -- optional
		config = function()
			require("mason").setup()
		end,
	},
	{
		"EdenEast/nightfox.nvim"
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
		config = lspDefaultConfig,
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			local autopairs = require("nvim-autopairs")
			autopairs.setup({
				check_ts = true, -- Check treesitter for context
				ts_config = {
					lua = { "string" }, -- don't add pairs in lua string
					javascript = { "template_string" },
					java = false,
				},
			})

			-- This is the crucial part for nvim-cmp integration
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			local cmp = require("cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},
	{
		"hrsh7th/nvim-cmp",
  dependencies = {
    -- Snippet Engine & Snippet Sources

		{
			"L3MON4D3/LuaSnip",
			-- Friendly snippets
			"rafamadriz/friendly-snippets",
		},
		"zbirenbaum/copilot-cmp",

    -- Basic Completion Sources
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-nvim-lua",
    "ray-x/cmp-treesitter",
    "hrsh7th/cmp-calc",
    "hrsh7th/cmp-emoji",
		"onsails/lspkind.nvim",

    -- Specialized Sources
    "folke/lazydev.nvim", -- For "lazydev"
    "roobert/tailwindcss-colorizer-cmp.nvim", -- For "tailwindcss"
    "lukas-reineke/cmp-rg", -- For "rg"
    "saecki/crates.nvim", -- For "crates"
    "petertriho/cmp-git", -- For "git"
  },
  opts = function(_, opts)
    -- Your existing opts function is fine
    opts.sources = opts.sources or {}
    table.insert(opts.sources, {
      name = "lazydev",
      group_index = 0,
    })
  end,
  config = function()


		require("copilot_cmp").setup()
    local cmp = require("cmp")
		local lspkind = require("lspkind")
    -- Your full cmp.setup() block goes here...
    cmp.setup({
      -- Add snippets capability
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<Tab>"] = cmp.mapping.confirm({ select = true }),
        ["<CR>"] = cmp.mapping.confirm({ select = true }), -- I'd recommend adding this too
      }),


			-- Formatting
			formatting = {
				format = lspkind.cmp_format({
					mode = "symbol_text", -- show symbol and text
					maxwidth = 50, -- prevent the popup from showing too wide
					ellipsis_char = "...", -- what to see when text is too long
					-- The function below will be called before any actual modifications from lspkind
					-- so that you can provide more controls on popup customization. (Optional)
					before = function(entry, vim_item)
						return vim_item
					end,
				}),
			},
      -- Your full sources list
      sources = {
        { name = "luasnip", priority = 150, group_index = 1 },
        { name = "tailwindcss", priority = 140, group_index = 1 },

        { name = "nvim_lsp", priority = 120, group_index = 1 },
        { name = "nvim_lua", priority = 110, group_index = 1 },

        { name = "lazydev", priority = 100, group_index = 1 },

				{ name = "copilot", max_item_count = 2, priority = 95, group_index = 1 },

        { name = "treesitter", max_item_count = 5, priority = 90, group_index = 2 },
        { name = "buffer", max_item_count = 5, priority = 80, group_index = 2 },
        { name = "rg", keyword_length = 4, max_item_count = 5, priority = 70, group_index = 2 },
        {
          name = "crates",
          priority = 100,
          group_index = 3,
          entry_filter = function()
            return vim.fn.filereadable("Cargo.toml") == 1
          end,
        },
        { name = "git", priority = 60, group_index = 3 },
        { name = "dap", priority = 60, group_index = 3 },
        { name = "path", priority = 50, group_index = 4 }, -- Note: Changed "async_path" to "path"
        { name = "calc", priority = 40, group_index = 4 },
        { name = "emoji", priority = 40, group_index = 4 },
      },
    })
  end,
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

	'mbbill/undotree',

	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim",         -- required
			"sindrets/diffview.nvim",        -- optional - Diff integration

			"nvim-telescope/telescope.nvim", -- optional
		},
		config = true
	}
}

