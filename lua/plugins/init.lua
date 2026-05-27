require("lazy").setup({{"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"}})

function lspDefaultConfig ()
	require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "basedpyright", "jdtls", "rust_analyzer", "vtsls" }, -- Adjust to your needs
				automatic_installation = true,
			})

			local capabilities = require("cmp_nvim_lsp").default_capabilities() -- Optional: integrate with nvim-cmp

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
						checkOnSave = true,
						diagnostics = {
							enableExperimental = true,
						},
					}
				},
			}

			vim.lsp.config['jdtls'] = {
				capabilities = capabilities,
				filetypes = { "java" }, -- Add supported file types
				cmd = { vim.fn.stdpath("data") .. "/mason/bin/jdtls" },
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
	-- {
		-- 'Julian/lean.nvim',
		-- event = { 'BufReadPre *.lean', 'BufNewFile *.lean' },
-- 
		-- dependencies = {
			-- 'nvim-lua/plenary.nvim',
-- 
			-- -- optional dependencies:
-- 
			-- -- a completion engine
			-- --    hrsh7th/nvim-cmp or Saghen/blink.cmp are popular choices
-- 
			-- -- 'nvim-telescope/telescope.nvim', -- for 2 Lean-specific pickers
			-- -- 'andymass/vim-matchup',          -- for enhanced % motion behavior
			-- -- 'andrewradev/switch.vim',        -- for switch support
			-- -- 'tomtom/tcomment_vim',           -- for commenting
		-- },
-- 
		-- ---@type lean.Config
		-- opts = { -- see below for full configuration options
			-- mappings = true,
		-- }
	-- },
	--'gen740/SmoothCursor.nvim',
	{
		"uhs-robert/oasis.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("oasis").setup()      -- (see Configuration below for all customization options)
			vim.cmd.colorscheme("oasis")  -- After setup, apply theme (or any style like "oasis-night")
		end
	},
	{ "catppuccin/nvim", name = "catppuccin" },
	--{"olimorris/codecompanion.nvim"},
	--{"rose-pine/neovim", as="rose-pine"},
	--{
		--"EdenEast/nightfox.nvim"
	--},
	{"ellisonleao/gruvbox.nvim"},
	{
		"nvimtools/none-ls.nvim",
	},
	'nvim-treesitter/nvim-treesitter',
	'nvim-tree/nvim-web-devicons',
	'akinsho/toggleterm.nvim',
	--{
    --'MeanderingProgrammer/render-markdown.nvim',
    --dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    -----@module 'render-markdown'
    -----@type render.md.UserConfig
    --opts = {

		--}
	--},

	{
		"lewis6991/gitsigns.nvim",
	},

	--{
		--"zbirenbaum/copilot.lua",
		--cmd = "Copilot",
		--event = "InsertEnter",
	--},

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
	--{
		--'nvim-lualine/lualine.nvim',
		--dependencies = { 'nvim-tree/nvim-web-devicons' }
	--},
	--{
		--'brenoprata10/nvim-highlight-colors'
	--},

	--{
		--"nvim-tree/nvim-web-devicons",
	--},

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
				},
			})

			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			local cmp = require("cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},
	{
		"hrsh7th/nvim-cmp",
  dependencies = {
    -- Snippet Engine & Snippet Sources

		--{
			--"L3MON4D3/LuaSnip",
			-- Friendly snippets
			--"rafamadriz/friendly-snippets",
		--},

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


    local cmp = require("cmp")
		local lspkind = require("lspkind")
    -- Your full cmp.setup() block goes here...
    cmp.setup({
      -- Add snippets capability
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
        { name = "nvim_lsp", priority = 120, group_index = 1 },
        { name = "nvim_lua", priority = 110, group_index = 1 },

        { name = "lazydev", priority = 100, group_index = 1 },

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

	{
		"jiaoshijie/undotree",
	},

	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim",         -- required
			"sindrets/diffview.nvim",        -- optional - Diff integration

			"nvim-telescope/telescope.nvim", -- optional
		},
		config = true
	},
	{
		"obsidian-nvim/obsidian.nvim",
	},
	{
			'MeanderingProgrammer/render-markdown.nvim',
			dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },            -- if you use the mini.nvim suite
			-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
			-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
			---@module 'render-markdown'
			opts = {},
	},

}
