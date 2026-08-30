-- ~/.config/nvim/lua/plugins.lua  (or lua/plugins/init.lua)
--
-- This file RETURNS a lazy.nvim spec. It must NOT call require("lazy").setup()
-- itself. Your init.lua should do the bootstrap + setup, e.g.:
--
--   vim.g.mapleader = " "
--   local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
--   if not (vim.uv or vim.loop).fs_stat(lazypath) then
--     vim.fn.system({ "git", "clone", "--filter=blob:none",
--       "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
--   end
--   vim.opt.rtp:prepend(lazypath)
--   require("lazy").setup("plugins")
--
-- Requires Neovim 0.11+ (uses vim.lsp.config / vim.lsp.enable).

---------------------------------------------------------------------------
-- Optional local config modules (guarded so a missing file doesn't break init)
---------------------------------------------------------------------------

local ok_key, api_key = pcall(require, "config.api_key")
API_KEY = ok_key and api_key or nil

local ok_py, python_path = pcall(require, "config.local_python_config")
PYTHON_PATH_FINDER = ok_py and python_path or nil

---------------------------------------------------------------------------
-- LSP setup (runs from mason-lspconfig's config function)
---------------------------------------------------------------------------

local function setup_lsp()
  -- capabilities from nvim-cmp, with a sane fallback
  local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
  local capabilities = ok_cmp and cmp_lsp.default_capabilities()
    or vim.lsp.protocol.make_client_capabilities()

  -- resolve a python interpreter if config.local_python_config gives one
  local python_interpreter
  if type(PYTHON_PATH_FINDER) == "function" then
    local ok, p = pcall(PYTHON_PATH_FINDER)
    python_interpreter = ok and p or nil
  elseif type(PYTHON_PATH_FINDER) == "string" then
    python_interpreter = PYTHON_PATH_FINDER
  end

  local servers = {
    lua_ls = {
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          diagnostics = { globals = { "vim" } },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false,
          },
        },
      },
    },

    basedpyright = {
      settings = {
        python = python_interpreter and { pythonPath = python_interpreter } or nil,
        basedpyright = {
          analysis = {
            typeCheckingMode = "standard",
            diagnosticMode = "openFilesOnly",
          },
        },
      },
    },

    jdtls = {
      filetypes = { "java" },
      -- Mason installs jdtls.cmd on Windows, jdtls elsewhere
      cmd = {
        vim.fn.stdpath("data")
          .. "/mason/bin/jdtls"
          .. (vim.fn.has("win32") == 1 and ".cmd" or ""),
      },
    },

    rust_analyzer = {
      filetypes = { "rust" },
      settings = {
        ["rust-analyzer"] = {
          cargo = {
            loadOutDirsFromCheck = true,
            allFeatures = true,
            allTargets = true,
            buildScripts = { enable = true },
          },
          procMacro = { enable = true },
          checkOnSave = true,
          -- NOTE: the old `diagnostics.enableExperimental` key was renamed
          diagnostics = { experimental = { enable = true } },
        },
      },
    },

    vtsls = {},

    tailwindcss = {
      filetypes = {
        "typescript",
        "typescriptreact",
        "javascript",
        "javascriptreact",
        "html",
        "css",
      },
    },
  }

  local server_names = vim.tbl_keys(servers)

  require("mason-lspconfig").setup({
    ensure_installed = server_names,
    -- we enable the servers ourselves below, so don't do it twice
    automatic_enable = false,
  })

  -- global defaults applied to every server
  vim.lsp.config("*", { capabilities = capabilities })

  for name, cfg in pairs(servers) do
    vim.lsp.config(name, cfg)
  end

  -- IMPORTANT: vim.lsp.config is not a plain table, so
  -- vim.lsp.enable(vim.tbl_keys(vim.lsp.config)) does NOT work.
  vim.lsp.enable(server_names)

  -- handy LSP keymaps, only bound when a server attaches
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local opts = { buffer = args.buf, silent = true }
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
      vim.keymap.set("n", "<leader>f", function()
        vim.lsp.buf.format({ async = true })
      end, opts)
    end,
  })
end

---------------------------------------------------------------------------
-- Plugin spec
---------------------------------------------------------------------------

return {
  ------------------------------------------------------------------ theme --
  {
    "uhs-robert/oasis.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("oasis").setup()
      vim.cmd.colorscheme("oasis")
    end,
  },
  { "catppuccin/nvim", name = "catppuccin", lazy = true },
  { "ellisonleao/gruvbox.nvim", lazy = true },

  ------------------------------------------------------------- completion --
  { "hrsh7th/cmp-nvim-lsp" },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        sources = {
          { name = "nvim_lsp" },
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = "select" }),
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = "select" }),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-u>"] = cmp.mapping.scroll_docs(-4),
          ["<C-d>"] = cmp.mapping.scroll_docs(4),
        }),
        snippet = {
          expand = function(args)
            vim.snippet.expand(args.body)
          end,
        },
      })
    end,
  },

  -------------------------------------------------------------------- LSP --
  -- mason.nvim and mason-lspconfig.nvim moved to the mason-org organisation
  {
    "mason-org/mason.nvim",
    build = ":MasonUpdate",
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = setup_lsp,
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
  {
    "MunifTanjim/prettier.nvim",
    dependencies = { "nvimtools/none-ls.nvim" },
    opts = {
      bin = "prettier",
      filetypes = {
        "css",
        "html",
        "javascript",
        "javascriptreact",
        "json",
        "markdown",
        "scss",
        "typescript",
        "typescriptreact",
        "yaml",
      },
    },
  },

------------------------------------------------------------- treesitter --
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup()

      require("nvim-treesitter").install({
        "lua", "vim", "vimdoc", "markdown", "markdown_inline",
        "rust", "python", "java", "typescript", "tsx", "javascript",
      })

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match)
          if not lang or not vim.treesitter.language.add(lang) then
            return
          end
          pcall(vim.treesitter.start, args.buf, lang)
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
  ------------------------------------------------------------------- misc --
	-- {
    -- 'milanglacier/minuet-ai.nvim',
    -- config = function()
        -- require('minuet').setup {
            -- provider = 'openai_fim_compatible',
            -- n_completions = 1,
            -- context_window = 1024,
            -- provider_options = {
                -- openai_fim_compatible = {
                    -- -- Minuet treats string values as environment variable names.
                    -- -- You can use a function returning a dummy string since Ollama doesn't require an API key.
                    -- api_key = 'TERM',
                    -- name = 'Ollama',
                    -- end_point = 'http://localhost:11434/v1/completions',
                    -- model = 'qwen2.5-coder:7b-instruct', -- Ensure this model is pulled in Ollama
                    -- optional = {
                        -- max_tokens = 350,
                        -- top_p = 0.9,
                    -- },
                -- },
            -- },
-- 
            -- virtualtext = {
                -- -- Enable auto-triggering for all filetypes (or list specific ones like {'lua', 'python'})
                -- auto_trigger_ft = { '*' },
                -- keymap = {
                    -- accept = '<A-A>',
                    -- accept_line = '<A-a>',
                    -- accept_n_lines = '<A-z>',
                    -- prev = '<A-[>',
                    -- next = '<A-]>',
                    -- dismiss = '<A-e>',
                -- },
            -- },
        -- }
    -- end,
-- },
  { "nvim-tree/nvim-web-devicons", lazy = true },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = { open_mapping = [[<c-\>]] },
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {},
  },
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    dependencies = { "hrsh7th/nvim-cmp" },
    config = function()
      local autopairs = require("nvim-autopairs")
      autopairs.setup({
        check_ts = true,
        ts_config = {
          lua = { "string" },
          javascript = { "template_string" },
        },
      })

      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },
  { "tpope/vim-abolish" },
  {
    "nvim-telescope/telescope.nvim",
    -- pick ONE of branch/tag, not both
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
  {
    "stevearc/oil.nvim",
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
  },
  {
    "jiaoshijie/undotree",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      { "<leader>u", "<cmd>lua require('undotree').toggle()<cr>", desc = "Undotree" },
    },
  },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = true,
  },

  -------------------------------------------------------------------- DAP --
  { "mfussenegger/nvim-dap" },
  { "nvim-neotest/nvim-nio" },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()
      dap.listeners.before.attach.dapui_config = dapui.open
      dap.listeners.before.launch.dapui_config = dapui.open
      dap.listeners.before.event_terminated.dapui_config = dapui.close
      dap.listeners.before.event_exited.dapui_config = dapui.close
    end,
  },

  ------------------------------------------------------------------ avante --
  -- Local fork checked out at ~/Repos/avante-claude. Options live in
  -- lua/config/avante_config.lua. Default keymaps: <leader>aa ask,
  -- <leader>ae edit (visual), <leader>at toggle sidebar, <leader>ar refresh.
  {
    "yetone/avante.nvim",
    dir = vim.fn.expand("~/Repos/avante-claude"),
    build = "make",
    event = "VeryLazy",
    version = false,
    ---@module 'avante'
    ---@type avante.Config
    opts = function()
      return require("config.avante_config")
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-telescope/telescope.nvim",
      "hrsh7th/nvim-cmp",
      "nvim-tree/nvim-web-devicons",
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = { file_types = { "markdown", "Avante" } },
        ft = { "markdown", "Avante" },
      },
    },
  },
}
