require("config.lazy")
require("config.dap_config")

-- Terminal 

-- Remove relative line numbers in terminal
vim.cmd([[au TermOpen term://* setlocal nonumber norelativenumber]])

local terminal = require("config.terminal_config")
vim.keymap.set("n", "<leader>nt", terminal.new_tab, { desc = "Open a new terminal tab" })
vim.keymap.set("n", "<leader>st", function()
  local height = 4
  vim.cmd("botright " .. height .. "split term://zsh")
  vim.cmd("startinsert")
end, { desc = "Open a small terminal at bottom" })

-- Copilot 
require("config.copilot_config")

-- hardtime
-- require("config.hardtime_config")

-- Tab config
local tab = require("config.tab_config")
vim.keymap.set("n", "<leader>1", function() tab.set_tab(1) end, { desc = "Go to tab 1" })
vim.keymap.set("n", "<leader>2", function() tab.set_tab(2) end, { desc = "Go to tab 2" })
vim.keymap.set("n", "<leader>3", function() tab.set_tab(3) end, { desc = "Go to tab 3" })
vim.keymap.set("n", "<leader>4", function() tab.set_tab(4) end, { desc = "Go to tab 4" })
vim.keymap.set("n", "<leader>5", function() tab.set_tab(5) end, { desc = "Go to tab 5" })
vim.keymap.set("n", "<leader>6", function() tab.set_tab(6) end, { desc = "Go to tab 6" })
vim.keymap.set("n", "<leader>7", function() tab.set_tab(7) end, { desc = "Go to tab 7" })
vim.keymap.set("n", "<leader>8", function() tab.set_tab(8) end, { desc = "Go to tab 8" })
vim.keymap.set("n", "<leader>9", function() tab.set_tab(9) end, { desc = "Go to tab 9" })

vim.keymap.set("n", "<leader>r1", function() tab.remove_tab(1) end, { desc = "Go to tab 1" })
vim.keymap.set("n", "<leader>r2", function() tab.remove_tab(2) end, { desc = "Go to tab 2" })
vim.keymap.set("n", "<leader>r3", function() tab.remove_tab(3) end, { desc = "Go to tab 3" })
vim.keymap.set("n", "<leader>r4", function() tab.remove_tab(4) end, { desc = "Go to tab 4" })
vim.keymap.set("n", "<leader>r5", function() tab.remove_tab(5) end, { desc = "Go to tab 5" })
vim.keymap.set("n", "<leader>r6", function() tab.remove_tab(6) end, { desc = "Go to tab 6" })
vim.keymap.set("n", "<leader>r7", function() tab.remove_tab(7) end, { desc = "Go to tab 7" })
vim.keymap.set("n", "<leader>r8", function() tab.remove_tab(8) end, { desc = "Go to tab 8" })
vim.keymap.set("n", "<leader>r9", function() tab.remove_tab(9) end, { desc = "Go to tab 9" })


-- Treesitter
require("config.treesitter_config")


-- API KEY
local function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function get_env_data()
	local env_file = "/Users/elliothegraeus/.config/nvim/.env"
	local env_data = ""
	local file = io.open(env_file, "r")
	if file then
		env_data = file:read("*a")
		file:close()
	else
		vim.notify("COULD NOT FIND ANTHROPIC KEY", vim.log.levels.INFO)
	end
	-- print too
	local key = trim(env_data:gsub("\r", ""))
	-- vim.notify("OPENAI_API_KEY: " .. tostring(key), vim.log.levels.INFO)
	return key
end


-- codecompanion setup
ANTHROPIC_API_KEY = get_env_data()
require("codecompanion").setup({
	strategies = {
		chat = {
			adapter = "anthropic",
			keymaps = {
				close = {
					modes = { n = "<C-x>", i = "<C-x>" },
				},
			},

		},
		inline = {
			adapter = "anthropic",
			keymaps = {
				accept_change = {
					modes = { n = "<Tab>" },
					description = "Accept the suggested change",
				},
				reject_change = {
					modes = { n = "<C-c>" },
					description = "Reject the suggested change",
				},
			},
		},
	},

	adapters = {
		anthropic = function()
			return require("codecompanion.adapters").extend("anthropic", {
				env = {
					api_key = ANTHROPIC_API_KEY,
				},
				schema = {
					model = {
						default = "claude-3-7-sonnet-latest",
					},
				},
			})
		end,
	},

  display = {
		chat = {
			window = {
				layout = "horizontal",
				positon = "top",
				height = 0.3,
			},
		},
		inline = {
			window = {
				layout = "horizontal",
				positon = "top",
				height = 0.3,
			},
		},
    action_palette = {
      width = 95,
      height = 10,
      prompt = "Prompt ",
      provider = "telescope",
      opts = {
        show_default_actions = true,
        show_default_prompt_library = true,
      },
    },
    buffer = {
      provider = "telescope", -- Add telescope provider for buffer command
    },
  },
})
vim.keymap.set({ "n", "v" }, "<leader>aa", "<CMD>CodeCompanionChat Toggle<CR>", { noremap = true, silent = true })
vim.keymap.set("v", "<leader>af", "<CMD>CodeCompanionChat Add<CR>", { noremap = true, silent = true })

-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd[[cab cc CodeCompanion]]

-- Lua line
--
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 100,
      tabline = 100,
      winbar = 100,
    },
		always_show_tabline = true,
  },
  sections = {
    lualine_a = {},
    lualine_b = {},
		lualine_c = {},
		lualine_x = {},
    lualine_y = {},
    lualine_z = {},
	},
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {
    lualine_a = {'filename'},
    lualine_b = {'filetype', 'fileformat', 'encoding'},
    lualine_c = {
			'datetime'

	},
    lualine_x = {'progress','location',
				{
					"tabs",
					cond = function()
						return #vim.fn.gettabinfo() > 1
					end,
				} 
			},
    lualine_y = {'diagnostics','diff', 'branch'},
    lualine_z = {'searchcount', 'selectioncount', 'mode'}
	},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}


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

-- Colors
--
vim.o.termguicolors = true  -- Enable true color support

require("nightfox").setup({
	options = {
		colorblind = {
			enable = true,
			-- simulate_only = true,
			severity = {
				-- protan = 1,
				-- deutan = 1,
				-- tritan = 1,
			}
		},
		transparent = true,
		terminal_colors = true,
		styles = {               -- Style to be applied to different syntax groups
			comments = "italic",     -- Value is any valid attr-list value `:help attr-list`
			conditionals = "italic",
			constants = "underdotted",
			functions = "bold",
			keywords = "italic",
			numbers = "italic",
			operators = "italic",
			strings = "italic",
			types = "bold",
			variables = "NONE",
		},
	},
})
vim.cmd[[colorscheme nightfox]]

require("nvim-highlight-colors").setup {
	---Render style
	---@usage 'background'|'foreground'|'virtual'
	render = 'background',

	---Set virtual symbol (requires render to be set to 'virtual')
	virtual_symbol = '■',

	---Set virtual symbol suffix (defaults to '')
	virtual_symbol_prefix = '',

	---Set virtual symbol suffix (defaults to ' ')
	virtual_symbol_suffix = ' ',

	---Set virtual symbol position()
 	---@usage 'inline'|'eol'|'eow'
 	---inline mimics VS Code style
 	---eol stands for `end of column` - Recommended to set `virtual_symbol_suffix = ''` when used.
 	---eow stands for `end of word` - Recommended to set `virtual_symbol_prefix = ' ' and virtual_symbol_suffix = ''` when used.
	virtual_symbol_position = 'inline',

	---Highlight hex colors, e.g. '#FFFFFF'
	enable_hex = true,

    	---Highlight short hex colors e.g. '#fff'
	enable_short_hex = true,

	---Highlight rgb colors, e.g. 'rgb(0 0 0)'
	enable_rgb = true,

	---Highlight hsl colors, e.g. 'hsl(150deg 30% 40%)'
	enable_hsl = true,

	---Highlight CSS variables, e.g. 'var(--testing-color)'
	enable_var_usage = true,

	---Highlight named colors, e.g. 'green'
	enable_named_colors = true,

	---Highlight tailwind colors, e.g. 'bg-blue-500'
	enable_tailwind = false,

	---Set custom colors
	---Label must be properly escaped with '%' to adhere to `string.gmatch`
	--- :help string.gmatch
	custom_colors = {
		{ label = '%-%-theme%-primary%-color', color = '#0f1219' },
		{ label = '%-%-theme%-secondary%-color', color = '#5a5d64' },
	},

 	-- Exclude filetypes or buftypes from highlighting e.g. 'exclude_buftypes = {'text'}'
    	exclude_filetypes = {},
    	exclude_buftypes = {}
}
-- Git config


require("diffview").setup({
  default_args = {
    DiffviewOpen = { "--split=horizontal" },  -- This would make DiffView split horizontally
  },
  -- Other DiffView configuration options...
})

local neogit = require("neogit")

vim.keymap.set("n", "<leader>gg", function () neogit.open() end)
vim.keymap.set("n", "<leader>gc", function () neogit.open({"commit"}) end)
vim.keymap.set("n", "<leader>ga", function () neogit.open({"add"}) end)

neogit.setup {
  -- Hides the hints at the top of the status buffer
  disable_hint = false,
  -- Disables changing the buffer highlights based on where the cursor is.
  disable_context_highlighting = false,
  -- Disables signs for sections/items/hunks
  disable_signs = false,
  -- Changes what mode the Commit Editor starts in. `true` will leave nvim in normal mode, `false` will change nvim to
  -- insert mode, and `"auto"` will change nvim to insert mode IF the commit message is empty, otherwise leaving it in
  -- normal mode.
  disable_insert_on_commit = "auto",
  -- When enabled, will watch the `.git/` directory for changes and refresh the status buffer in response to filesystem
  -- events.
  filewatcher = {
    interval = 1000,
    enabled = true,
  },
  -- "ascii"   is the graph the git CLI generates
  -- "unicode" is the graph like https://github.com/rbong/vim-flog
  -- "kitty"   is the graph like https://github.com/isakbm/gitgraph.nvim - use https://github.com/rbong/flog-symbols if you don't use Kitty
  graph_style = "ascii",
  -- Show relative date by default. When set, use `strftime` to display dates
  commit_date_format = nil,
  log_date_format = nil,
  -- Show message with spinning animation when a git command is running.
  process_spinner = false,
  -- Used to generate URL's for branch popup action "pull request".
  git_services = {
    ["github.com"] = "https://github.com/${owner}/${repository}/compare/${branch_name}?expand=1",
    ["bitbucket.org"] = "https://bitbucket.org/${owner}/${repository}/pull-requests/new?source=${branch_name}&t=1",
    ["gitlab.com"] = "https://gitlab.com/${owner}/${repository}/merge_requests/new?merge_request[source_branch]=${branch_name}",
    ["azure.com"] = "https://dev.azure.com/${owner}/_git/${repository}/pullrequestcreate?sourceRef=${branch_name}&targetRef=${target}",
  },
  -- Allows a different telescope sorter. Defaults to 'fuzzy_with_index_bias'. The example below will use the native fzf
  -- sorter instead. By default, this function returns `nil`.
  telescope_sorter = function()
    return require("telescope").extensions.fzf.native_fzf_sorter()
  end,
  -- Persist the values of switches/options within and across sessions
  remember_settings = true,
  -- Scope persisted settings on a per-project basis
  use_per_project_settings = true,
  -- Table of settings to never persist. Uses format "Filetype--cli-value"
  ignored_settings = {
    "NeogitPushPopup--force-with-lease",
    "NeogitPushPopup--force",
    "NeogitPullPopup--rebase",
    "NeogitCommitPopup--allow-empty",
    "NeogitRevertPopup--no-edit",
  },
  -- Configure highlight group features
  highlight = {
    italic = true,
    bold = true,
    underline = true
  },
  -- Set to false if you want to be responsible for creating _ALL_ keymappings
  use_default_keymaps = true,
  -- Neogit refreshes its internal state after specific events, which can be expensive depending on the repository size.
  -- Disabling `auto_refresh` will make it so you have to manually refresh the status after you open it.
  auto_refresh = true,
  -- Value used for `--sort` option for `git branch` command
  -- By default, branches will be sorted by commit date descending
  -- Flag description: https://git-scm.com/docs/git-branch#Documentation/git-branch.txt---sortltkeygt
  -- Sorting keys: https://git-scm.com/docs/git-for-each-ref#_options
  sort_branches = "-committerdate",
  -- Default for new branch name prompts
  initial_branch_name = "",
  -- Change the default way of opening neogit
  kind = "tab",
  -- Disable line numbers
  disable_line_numbers = true,
  -- Disable relative line numbers
  disable_relative_line_numbers = true,
  -- The time after which an output console is shown for slow running commands
  console_timeout = 2000,
  -- Automatically show console if a command takes more than console_timeout milliseconds
  auto_show_console = true,
  -- Automatically close the console if the process exits with a 0 (success) status
  auto_close_console = true,
  notification_icon = "󰊢",
  status = {
    show_head_commit_hash = true,
    recent_commit_count = 10,
    HEAD_padding = 10,
    HEAD_folded = false,
    mode_padding = 3,
    mode_text = {
      M = "modified",
      N = "new file",
      A = "added",
      D = "deleted",
      C = "copied",
      U = "updated",
      R = "renamed",
      DD = "unmerged",
      AU = "unmerged",
      UD = "unmerged",
      UA = "unmerged",
      DU = "unmerged",
      AA = "unmerged",
      UU = "unmerged",
      ["?"] = "",
    },
  },
  commit_editor = {
    kind = "tab",
    show_staged_diff = true,
    -- Accepted values:
    -- "split" to show the staged diff below the commit editor
    -- "vsplit" to show it to the right
    -- "split_above" Like :top split
    -- "vsplit_left" like :vsplit, but open to the left
    -- "auto" "vsplit" if window would have 80 cols, otherwise "split"
    staged_diff_split_kind = "split",
    spell_check = true,
  },
  commit_select_view = {
    kind = "tab",
  },
  commit_view = {
    kind = "vsplit",
    verify_commit = vim.fn.executable("gpg") == 1, -- Can be set to true or false, otherwise we try to find the binary
  },
  log_view = {
    kind = "tab",
  },
  rebase_editor = {
    kind = "auto",
  },
  reflog_view = {
    kind = "tab",
  },
  merge_editor = {
    kind = "auto",
  },
  description_editor = {
    kind = "auto",
  },
  tag_editor = {
    kind = "auto",
  },
  preview_buffer = {
    kind = "split_below",
  },
  popup = {
    kind = "split",
  },
  stash = {
    kind = "tab",
  },
  refs_view = {
    kind = "tab",
  },
  signs = {
    -- { CLOSED, OPENED }
    hunk = { "", "" },
    item = { ">", "v" },
    section = { ">", "v" },
  },
  -- Each Integration is auto-detected through plugin presence, however, it can be disabled by setting to `false`
  integrations = {
    -- If enabled, use telescope for menu selection rather than vim.ui.select.
    -- Allows multi-select and some things that vim.ui.select doesn't.
    telescope = nil,
    -- Neogit only provides inline diffs. If you want a more traditional way to look at diffs, you can use `diffview`.
    -- The diffview integration enables the diff popup.
    --
    -- Requires you to have `sindrets/diffview.nvim` installed.
    diffview = nil,

    fzf_lua = nil,

    mini_pick = nil,
  },
  sections = {
    -- Reverting/Cherry Picking
    sequencer = {
      folded = false,
      hidden = false,
    },
    untracked = {
      folded = false,
      hidden = false,
    },
    unstaged = {
      folded = false,
      hidden = false,
    },
    staged = {
      folded = false,
      hidden = false,
    },
    stashes = {
      folded = true,
      hidden = false,
    },
    unpulled_upstream = {
      folded = true,
      hidden = false,
    },
    unmerged_upstream = {
      folded = false,
      hidden = false,
    },
    unpulled_pushRemote = {
      folded = true,
      hidden = false,
    },
    unmerged_pushRemote = {
      folded = false,
      hidden = false,
    },
    recent = {
      folded = true,
      hidden = false,
    },
    rebase = {
      folded = true,
      hidden = false,
    },
  },
  mappings = {
    commit_editor = {
      ["q"] = "Close",
      ["<c-c><c-c>"] = "Submit",
      ["<c-c><c-k>"] = "Abort",
      ["<m-p>"] = "PrevMessage",
      ["<m-n>"] = "NextMessage",
      ["<m-r>"] = "ResetMessage",
    },
    commit_editor_I = {
      ["<c-c><c-c>"] = "Submit",
      ["<c-c><c-k>"] = "Abort",
    },
    rebase_editor = {
      ["p"] = "Pick",
      ["r"] = "Reword",
      ["e"] = "Edit",
      ["s"] = "Squash",
      ["f"] = "Fixup",
      ["x"] = "Execute",
      ["d"] = "Drop",
      ["b"] = "Break",
      ["q"] = "Close",
      ["<cr>"] = "OpenCommit",
      ["gk"] = "MoveUp",
      ["gj"] = "MoveDown",
      ["<c-c><c-c>"] = "Submit",
      ["<c-c><c-k>"] = "Abort",
      ["[c"] = "OpenOrScrollUp",
      ["]c"] = "OpenOrScrollDown",
    },
    rebase_editor_I = {
      ["<c-c><c-c>"] = "Submit",
      ["<c-c><c-k>"] = "Abort",
    },
    finder = {
      ["<cr>"] = "Select",
      ["<c-c>"] = "Close",
      ["<esc>"] = "Close",
      ["<c-n>"] = "Next",
      ["<c-p>"] = "Previous",
      ["<down>"] = "Next",
      ["<up>"] = "Previous",
      ["<tab>"] = "InsertCompletion",
      ["<space>"] = "MultiselectToggleNext",
      ["<s-space>"] = "MultiselectTogglePrevious",
      ["<c-j>"] = "NOP",
      ["<ScrollWheelDown>"] = "ScrollWheelDown",
      ["<ScrollWheelUp>"] = "ScrollWheelUp",
      ["<ScrollWheelLeft>"] = "NOP",
      ["<ScrollWheelRight>"] = "NOP",
      ["<LeftMouse>"] = "MouseClick",
      ["<2-LeftMouse>"] = "NOP",
    },
    -- Setting any of these to `false` will disable the mapping.
    popup = {
      ["?"] = "HelpPopup",
      ["A"] = "CherryPickPopup",
      ["d"] = "DiffPopup",
      ["M"] = "RemotePopup",
      ["P"] = "PushPopup",
      ["X"] = "ResetPopup",
      ["Z"] = "StashPopup",
      ["i"] = "IgnorePopup",
      ["t"] = "TagPopup",
      ["b"] = "BranchPopup",
      ["B"] = "BisectPopup",
      ["w"] = "WorktreePopup",
      ["c"] = "CommitPopup",
      ["f"] = "FetchPopup",
      ["l"] = "LogPopup",
      ["m"] = "MergePopup",
      ["p"] = "PullPopup",
      ["r"] = "RebasePopup",
      ["v"] = "RevertPopup",
    },
    status = {
      ["j"] = "MoveDown",
      ["k"] = "MoveUp",
      ["o"] = "OpenTree",
      ["q"] = "Close",
      ["I"] = "InitRepo",
      ["1"] = "Depth1",
      ["2"] = "Depth2",
      ["3"] = "Depth3",
      ["4"] = "Depth4",
      ["Q"] = "Command",
      ["<tab>"] = "Toggle",
      ["x"] = "Discard",
      ["s"] = "Stage",
      ["S"] = "StageUnstaged",
      ["<c-s>"] = "StageAll",
      ["u"] = "Unstage",
      ["K"] = "Untrack",
      ["U"] = "UnstageStaged",
      ["y"] = "ShowRefs",
      ["$"] = "CommandHistory",
      ["Y"] = "YankSelected",
      ["<c-r>"] = "RefreshBuffer",
      ["<cr>"] = "GoToFile",
      ["<s-cr>"] = "PeekFile",
      ["<c-v>"] = "VSplitOpen",
      ["<c-x>"] = "SplitOpen",
      ["<c-t>"] = "TabOpen",
      ["{"] = "GoToPreviousHunkHeader",
      ["}"] = "GoToNextHunkHeader",
      ["[c"] = "OpenOrScrollUp",
      ["]c"] = "OpenOrScrollDown",
      ["<c-k>"] = "PeekUp",
      ["<c-j>"] = "PeekDown",
      ["<c-n>"] = "NextSection",
      ["<c-p>"] = "PreviousSection",
    },
  },
}


-- vim.keymap.set("n", "<leader>gs", ":Git<CR>", { desc = "Open Git status" })
-- vim.keymap.set("n", "<leader>gc", ":Git commit -m '", { desc = "Open Git commit" })
-- vim.keymap.set("n", "<leader>ga", ":Git add -u<CR>'", { desc = "Open Git add" })
-- vim.keymap.set("n", "<leader>gq", ":Git add ", { desc = "Open Git add" })
-- vim.keymap.set("n", "<leader>gp", ":Git pull<CR>", { desc = "Open Git pull" })
-- vim.keymap.set("n", "<leader>gf", ":Git push<CR>", { desc = "Open Git push" })
-- vim.keymap.set("n", "<leader>gh", ":Gdiffsplit<CR>", { desc = "Open Git diff" })
-- vim.keymap.set("n", "<leader>gg", ":Git difftool<CR>", { desc = "Open Git diff" })
-- vim.keymap.set("n", "]g", "<cmd>cnext<CR>", { noremap = true, silent = true })
-- vim.keymap.set("n", "[g", "<cmd>cprev<CR>", { noremap = true, silent = true })

-- Baseic config
vim.keymap.set('n', '<C-[>', '<C-w>h', { noremap = true, silent = true })
vim.keymap.set('n', '<C-j>', '<C-w>j', { noremap = true, silent = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { noremap = true, silent = true })
vim.keymap.set('n', '<C-]>', '<C-w>l', { noremap = true, silent = true })

-- Window splitting (right and down)
vim.keymap.set('n', '<leader>wd', '<C-w>s', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>wf', '<C-w>v', { noremap = true, silent = true })

-- Window resizing
vim.keymap.set('n', '<leader>wh', '5<C-w><', { noremap = true, silent = true, desc = "Decrease width" })
vim.keymap.set('n', '<leader>wl', '5<C-w>>', { noremap = true, silent = true, desc = "Increase width" })
vim.keymap.set('n', '<leader>wk', '5<C-w>+', { noremap = true, silent = true, desc = "Increase height" })
vim.keymap.set('n', '<leader>wj', '5<C-w>-', { noremap = true, silent = true, desc = "Decrease height" })

vim.keymap.set('n', '<leader>wH', '50<C-w><', { noremap = true, silent = true, desc = "Decrease width" })
vim.keymap.set('n', '<leader>wL', '50<C-w>>', { noremap = true, silent = true, desc = "Increase width" })
vim.keymap.set('n', '<leader>wK', '50<C-w>+', { noremap = true, silent = true, desc = "Increase height" })
vim.keymap.set('n', '<leader>wJ', '50<C-w>-', { noremap = true, silent = true, desc = "Decrease height" })

vim.cmd([[highlight WinSeparator guifg=#4e545c guibg=None]])


vim.opt.clipboard:append { 'unnamedplus' }

-- Harpoon config

require("config.harpoon_config")

-- Oil config

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

require("oil").setup({
	keymaps = {
		["g?"] = { "actions.show_help", mode = "n" },
    ["<CR>"] = "actions.select",
    ["<C-s>"] = { "actions.select", opts = { vertical = true } },
    ["<C-h>"] = { "actions.select", opts = { horizontal = true } },
    ["<C-t>"] = { "actions.select", opts = { tab = true } },
    ["<C-p>"] = "actions.preview",
    ["<C-c>"] = { "actions.close", mode = "n" },
    ["<C-l>"] = "actions.refresh",
    ["-"] = { "actions.parent", mode = "n" },
    ["_"] = { "actions.open_cwd", mode = "n" },
    ["`"] = { "actions.cd", mode = "n" },
    ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
    ["gs"] = { "actions.change_sort", mode = "n" },
    ["gx"] = "actions.open_external",
    ["g."] = { "actions.toggle_hidden", mode = "n" },
    ["g\\"] = { "actions.toggle_trash", mode = "n" }
  },

	-- Oil will take over directory buffers (e.g. `vim .` or `:e src/`)
	-- Set to false if you want some other plugin (e.g. netrw) to open when you edit directories.
	default_file_explorer = true,
	-- Id is automatically added at the beginning, and name at the end
	-- See :help oil-columns
	columns = {
		"icon",
		-- "permissions",
		-- "size",
		-- "mtime",
	},

	-- Buffer-local options to use for oil buffers
	buf_options = {
		buflisted = false,
		bufhidden = "hide",
	},

	-- Window-local options to use for oil buffers
	win_options = {
		wrap = false,
		signcolumn = "no",
		cursorcolumn = false,
		foldcolumn = "0",
		spell = false,
		list = false,
		conceallevel = 3,
		concealcursor = "nvic",
	},
	-- Send deleted files to the trash instead of permanently deleting them (:help oil-trash)
	delete_to_trash = false,
	-- Skip the confirmation popup for simple operations (:help oil.skip_confirm_for_simple_edits)
	skip_confirm_for_simple_edits = false,
	-- Selecting a new/moved/renamed file or directory will prompt you to save changes first
	-- (:help prompt_save_on_select_new_entry)
	prompt_save_on_select_new_entry = true,
	-- Oil will automatically delete hidden buffers after this delay
	-- You can set the delay to false to disable cleanup entirely
	-- Note that the cleanup process only starts when none of the oil buffers are currently displayed
	cleanup_delay_ms = 2000,
	lsp_file_methods = {
		-- Time to wait for LSP file operations to complete before skipping
		timeout_ms = 1000,
		-- Set to true to autosave buffers that are updated with LSP willRenameFiles
		-- Set to "unmodified" to only save unmodified buffers
		autosave_changes = false,
	},
	-- Constrain the cursor to the editable parts of the oil buffer
	-- Set to `false` to disable, or "name" to keep it on the file names
	constrain_cursor = "editable",
	-- Set to true to watch the filesystem for changes and reload oil
	watch_for_changes = false,
	-- Keymaps in oil buffer. Can be any value that `vim.keymap.set` accepts OR a table of keymap
	-- options with a `callback` (e.g. { callback = function() ... end, desc = "", mode = "n" })
	-- Additionally, if it is a string that matches "actions.<name>",
	-- it will use the mapping at require("oil.actions").<name>
	-- Set to `false` to remove a keymap
	-- See :help oil-actions for a list of all available actions
	keymaps = {
		["g?"] = "actions.show_help",
		["<CR>"] = "actions.select",
		["<C-s>"] = { "actions.select", opts = { vertical = true }, desc = "Open the entry in a vertical split" },
		["<C-h>"] = { "actions.select", opts = { horizontal = true }, desc = "Open the entry in a horizontal split" },
		["<C-t>"] = { "actions.select", opts = { tab = true }, desc = "Open the entry in new tab" },
		["<C-p>"] = "actions.preview",
		["<C-c>"] = "actions.close",
		["<C-l>"] = "actions.refresh",
		["-"] = "actions.parent",
		["_"] = "actions.open_cwd",
		["`"] = "actions.cd",
		["~"] = { "actions.cd", opts = { scope = "tab" }, desc = ":tcd to the current oil directory" },
		["gs"] = "actions.change_sort",
		["gx"] = "actions.open_external",
		["g."] = "actions.toggle_hidden",
		["g\\"] = "actions.toggle_trash",
	},
	-- Set to false to disable all of the above keymaps
	use_default_keymaps = true,
	view_options = {
		-- Show files and directories that start with "."
		show_hidden = false,
		-- This function defines what is considered a "hidden" file
		is_hidden_file = function(name, bufnr)
			return vim.startswith(name, ".")
		end,
		-- This function defines what will never be shown, even when `show_hidden` is set
		is_always_hidden = function(name, bufnr)
			return false
		end,
		-- Sort file names in a more intuitive order for humans. Is less performant,
		-- so you may want to set to false if you work with large directories.
		natural_order = true,
		-- Sort file and directory names case insensitive
		case_insensitive = false,
		sort = {
			-- sort order can be "asc" or "desc"
			-- see :help oil-columns to see which columns are sortable
			{ "type", "asc" },
			{ "name", "asc" },
		},
	},
	-- Extra arguments to pass to SCP when moving/copying files over SSH
	extra_scp_args = {},
	-- EXPERIMENTAL support for performing file operations with git
	git = {
		-- Return true to automatically git add/mv/rm files
		add = function(path)
			return false
		end,
		mv = function(src_path, dest_path)
			return false
		end,
		rm = function(path)
			return false
		end,
	},
	-- Configuration for the floating window in oil.open_float
	float = {
		-- Padding around the floating window
		padding = 2,
		max_width = 0,
		max_height = 0,
		border = "rounded",
		win_options = {
			winblend = 0,
		},
		-- preview_split: Split direction: "auto", "left", "right", "above", "below".
		preview_split = "auto",
		-- This is the config that will be passed to nvim_open_win.
		-- Change values here to customize the layout
		override = function(conf)
			return conf
		end,
	},
	-- Configuration for the actions floating preview window
	preview = {
		-- Width dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
		-- min_width and max_width can be a single value or a list of mixed integer/float types.
		-- max_width = {100, 0.8} means "the lesser of 100 columns or 80% of total"
		max_width = 0.9,
		-- min_width = {40, 0.4} means "the greater of 40 columns or 40% of total"
		min_width = { 40, 0.4 },
		-- optionally define an integer/float for the exact width of the preview window
		width = nil,
		-- Height dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
		-- min_height and max_height can be a single value or a list of mixed integer/float types.
		-- max_height = {80, 0.9} means "the lesser of 80 columns or 90% of total"
		max_height = 0.9,
		-- min_height = {5, 0.1} means "the greater of 5 columns or 10% of total"
		min_height = { 5, 0.1 },
		-- optionally define an integer/float for the exact height of the preview window
		height = nil,
		border = "rounded",
		win_options = {
			winblend = 0,
		},
		-- Whether the preview window is automatically updated when the cursor is moved
		update_on_cursor_moved = true,
	},
	-- Configuration for the floating progress window
	progress = {
		max_width = 0.9,
		min_width = { 40, 0.4 },
		width = nil,
		max_height = { 10, 0.9 },
		min_height = { 5, 0.1 },
		height = nil,
		border = "rounded",
		minimized_border = "none",
		win_options = {
			winblend = 0,
		},
	},
	-- Configuration for the floating SSH window
	ssh = {
		border = "rounded",
	},
	-- Configuration for the floating keymaps help window
	keymaps_help = {
		border = "rounded",
	},
})

-- UndoTree git config
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

vim.o.undofile = true
vim.g.undotree_WindowLayout = 2

-- Copilot config
-- Default disabled
vim.g.copilot_enabled = 0


-- Function to replace occurrences of the first string with the second string in a given range
function ReplaceInRange(from, to)
  -- Construct the command using the given inputs
  local command = string.format(":'<,'>s/%s/%s/g", from, to)
  -- Execute the command in Vim
  vim.cmd(command)
end

-- Bind function to a custom command that works in visual mode
vim.api.nvim_exec([[
  command! -range -nargs=+ ReplaceInRange lua ReplaceInRange(<f-args>)
]], false)

-- Buffer swap
vim.api.nvim_set_keymap('n', '[a', ':bprev<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', ']a', ':bnext<CR>', { noremap = true, silent = true })

vim.keymap.set('n', '<leader>ce', ':Copilot enable<CR>', { desc = 'Enable Copilot' })
vim.keymap.set('n', '<leader>cr', ':Copilot disable<CR>', { desc = 'Disable Copilot' })

vim.keymap.set('n', '<leader><Tab>', 'copilot#Accept("\\<CR>")', {
  expr = true,
  replace_keycodes = false
})

-- Old config stuff
vim.g.mapleader = " "

-- Telescope 

vim.keymap.set('n', '<leader>cf', function ()
	require('telescope.builtin').live_grep()	
end)

vim.keymap.set('n', '<leader>cd', function ()
	require('telescope.builtin').find_files()
end)

vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- buffer config and opts

vim.keymap.set('n', '<leader>[a', "<CMD>bprev<CR>", { desc = 'Go buffer prev' })
vim.keymap.set('n', '<leader>]a', "<CMD>bnext<CR>", { desc = 'Go buffer next' })

vim.opt.relativenumber = true
vim.opt.scrolloff = 30
vim.opt.cursorline = true
vim.opt.inccommand = 'split'
vim.opt.timeoutlen = 300
vim.opt.updatetime = 250
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.number = true
vim.g.have_nerd_font = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 4
vim.opt.number = true
vim.opt.showtabline = 1

-- Toggle diagnostic visibility
vim.keymap.set('n', '<leader>td', function()
  local diagnostics_visible = vim.diagnostic.is_disabled()
  if diagnostics_visible then
    vim.diagnostic.enable()
    vim.notify("Diagnostics enabled", vim.log.levels.INFO)
  else
    vim.diagnostic.disable()
    vim.notify("Diagnostics disabled", vim.log.levels.INFO)
  end
end, { desc = "Toggle diagnostic visibility" })

function LineNumberColors()
    vim.api.nvim_set_hl(0, 'LineNrAbove', { fg='#51B3EC', bold=true })
    vim.api.nvim_set_hl(0, 'LineNr', { fg='white', bold=true })
    vim.api.nvim_set_hl(0, 'LineNrBelow', { fg='#FB508F', bold=true })
end

-- Function to set a mark with <C-g> in normal mode, or go to mark if mark is set
vim.keymap.set('n', 'm', '<Nop>', { noremap = true })
vim.keymap.set('n', '`', '<Nop>', { noremap = true })



-- Map <C-g> to set marks (waits for next character)
vim.keymap.set('n', '<C-g>', function()
    local mark_val = vim.fn.getchar()
    if mark_val == 0 then
        return
    end
    
    -- Handle control keys (ASCII 1-26)
    local mark
    if mark_val >= 1 and mark_val <= 26 then
        mark = string.char(mark_val + 96) -- Convert to lowercase letter
    else
        mark = string.char(mark_val)
    end
    
    local line = vim.fn.line('.')
    local col = vim.fn.col('.')
    vim.fn.setpos("'" .. mark, {0, line, col, 0})
    print("Mark '" .. mark .. "' set")
end, { noremap = true })

-- Map <C-h> to jump to marks (waits for next character)
vim.keymap.set('n', '<C-h>', function()
    local mark_val = vim.fn.getchar()
    if mark_val == 0 then
        return
    end
    
    -- Handle control keys (ASCII 1-26)
    local mark
    if mark_val >= 1 and mark_val <= 26 then
        mark = string.char(mark_val + 96) -- Convert to lowercase letter
    else
        mark = string.char(mark_val)
    end
    
    local pos = vim.fn.getpos("'" .. mark)
    if pos[2] == 0 then
        print("Mark '" .. mark .. "' not set")
        return
    end
    vim.cmd("normal! '" .. mark)
end, { noremap = true })


-- Swap "c" with "d" in normal mode
-- vim.keymap.set('n', 'd', 'c', {noremap = true})
-- vim.keymap.set('n', 'c', 'd', {noremap = true})
-- vim.keymap.set('v', 'd', 'c', {noremap = true})
-- vim.keymap.set('v', 'c', 'd', {noremap = true})
-- vim.keymap.set('n', 'dd', 'cc', {noremap = true})
-- vim.keymap.set('n', 'cc', 'dd', {noremap = true})
-- vim.keymap.set('n', 'D', 'C', {noremap = true})
-- vim.keymap.set('n', 'C', 'D', {noremap = true})
-- vim.keymap.set('v', 'D', 'C', {noremap = true})
-- vim.keymap.set('v', 'C', 'D', {noremap = true})

LineNumberColors()

