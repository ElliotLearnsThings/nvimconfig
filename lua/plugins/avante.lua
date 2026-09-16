-- avante.nvim (local fork at ~/Repos/avante.nvim) using the Claude Code ACP harness.
--
-- The fork is loaded from disk via lazy.nvim's `dir`, so edits in the repo take
-- effect on the next nvim start without reinstalling. Native Rust libs are built
-- with `make BUILD_FROM_SOURCE=true` in that repo (lua/avante_*.so).
--
-- Requires on PATH: `claude` (Claude Code CLI, logged in) and `claude-agent-acp`
-- (npm i -g @zed-industries/claude-agent-acp).

local avante_dir = vim.fn.expand("~/Repos/avante.nvim")

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
