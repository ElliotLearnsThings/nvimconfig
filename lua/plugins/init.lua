require("lazy").setup({{"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"}})



local function get_api_key()

	local api_key = require("config.api_key")
	-- vim.notify(api_key, vim.log.levels.INFO)
	return api_key
end

API_KEY = get_api_key()

PYTHON_PATH_FINDER = require("config.local_python_config")

return {
	{
		"ThePrimeagen/vim-be-good",
	},
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		version = false, -- Never set this value to "*"! Never!
		opts = {
			-- add any opts here
			-- for example
		provider = "claude",
		claude = {
				model = "claude-3-7-sonnet-20250219", -- You can use other Claude models as well
				-- api_key = API_KEY
			},
		},
		--behaviour = {
			--enable_claude_text_editor_tool_mode = true,
		--},
		-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
		build = "make",
		-- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			--- The below dependencies are optional,
			"echasnovski/mini.pick", -- for file_selector provider mini.pick
			"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
			"hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
			"ibhagwan/fzf-lua", -- for file_selector provider fzf
			"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
			{
				-- support for image pasting
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					-- recommended settings
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = {
							insert_mode = true,
						},
						-- required for Windows users
						use_absolute_path = true,
					},
				},
			},
			{
				-- Make sure to set this up properly if you have lazy=true
				'MeanderingProgrammer/render-markdown.nvim',
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
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
		"github/copilot.vim"
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
		'jose-elias-alvarez/null-ls.nvim',
	},
	{
		'neovim/nvim-lspconfig',
	},

	{
		"nvim-tree/nvim-web-devicons",
	},
	{

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
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls" }, -- Adjust to your needs
				automatic_installation = true,
			})

			local lspconfig = require("lspconfig")
			local capabilities = require("cmp_nvim_lsp").default_capabilities() -- Optional: integrate with nvim-cmp

			local PYTHON_PATH = PYTHON_PATH_FINDER.get_python_path_wrapper(vim.fn.getcwd(), false)

			if PYTHON_PATH then
				lspconfig.pylsp.setup({
					root_dir = function(fname)
						return vim.fn.getcwd()
					end,
					cmd = { PYTHON_PATH, "-m", "pylsp" },
					capabilities = capabilities,
					filetypes = { "python" },
					-- Ignore whitespace warnings (E305, E501)
					settings = {
						pylsp = {
							plugins = {
								flake8 = { enabled = true, ignore = { "E501", "E305", "E303", "E302" } },
								pycodestyle = { enabled = false },
								pyflakes = { enabled = false },
								mccabe = { enabled = false },
								pylsp_mypy = {
									enabled = true,
									live_mode = true,
									dmypy = false,
								},
								rope_completion = { enabled = true },
								rope_autoimport = { enabled = true, memory = true },
								jedi_completion = {
									enabled = true,
									include_params = true,
									include_class_objects = true,
									include_function_objects = true,
									fuzzy = true
								},
							},
						},
					},

				})
			end

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

			lspconfig.rust_analyzer.setup({
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
					})

			lspconfig.tailwindcss.setup({
			 	capabilities = capabilities,
				filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" }, -- Add supported file types
			})


			require('lspconfig').sqlls.setup {
				cmd = { "sql-language-server", "up", "--method", "stdio" },
				filetypes = { "sql" },
				root_dir = function(fname)
					return vim.fn.getcwd()
				end,
				settings = {}
			}
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

		end,
	},

	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
		},
		opts = function(_, opts)
			opts.sources = opts.sources or {}
			table.insert(opts.sources, {
				name = "lazydev",
				group_index = 0, -- set group index to 0 to skip loading LuaLS completions
			})
		end,
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
		priority = 0,
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

