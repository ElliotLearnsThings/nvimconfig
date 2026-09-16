-- avante.nvim (local fork at ~/Work/avante-local) using the Claude Code ACP harness.
--
-- The fork is loaded from disk via lazy.nvim's `dir`, so edits in the repo take
-- effect on the next nvim start without reinstalling. Native Rust libs are built
-- with `make BUILD_FROM_SOURCE=true` in that repo (lua/avante_*.so).
--
-- Requires on PATH: `claude` (Claude Code CLI, logged in) and `claude-agent-acp`
-- (local fork at ~/Work/claude-agent-acp-local, exposed via `npm link`).

local avante_dir = vim.fn.expand("~/Work/avante-local")

return {
	{
		"yetone/avante.nvim",
		dir = avante_dir,
		-- The fork is the source of truth; `dir` loads it in place and `pin`
		-- keeps lazy's updater from touching the working tree.
		pin = true,
		event = "VeryLazy",
		version = false,
		---@module 'avante'
		---@type avante.Config
		opts = {
			-- Drive avante through the Claude Code CLI over ACP. The default
			-- acp_providers["claude-code"] entry already points
			-- CLAUDE_CODE_EXECUTABLE at `vim.fn.exepath("claude")`, so no
			-- override is needed here and no ANTHROPIC_API_KEY is required
			-- while the CLI is logged in.
			provider = "claude-code",
			instructions_file = "avante.md",
			behaviour = {
				-- Open files and jump to the lines the agent edits.
				acp_follow_agent_locations = true,
			},
			windows = {
				-- Two columns instead of a stack: the agent's output keeps a
				-- full-height window of its own, with the prompt input beside
				-- it on the right.
				width = 35,
				-- Sidebar share while <leader>aa has the output or input largest.
				focus_width = 70,
				input = {
					position = "right",
					width = 35, -- % of the sidebar width
				},
			},
			mappings = {
				-- Sharing the ask key: opens avante when closed, otherwise cycles
				-- output largest -> input largest -> code largest -> minimised.
				-- Visual mode still sends the selection to ask.
				cycle_view = "<leader>aa",
			},
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			-- Optional, but already part of this config:
			"nvim-telescope/telescope.nvim", -- file_selector provider
			"hrsh7th/nvim-cmp", -- completion for avante commands/mentions
			"nvim-tree/nvim-web-devicons",
		},
	},
}
