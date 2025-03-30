-- API KEY
local function trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function get_env_data()
	local env_file = "/home/elliothegraeus/.config/nvim/.env"
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
	-- vim.notify("ANTHROPIC_API_KEY: " .. tostring(key), vim.log.levels.INFO)
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
						default = "claude-3-7-sonnet-extended-thinking",
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

