-- avante.nvim options (returned as a table; consumed by the lazy spec in
-- lua/plugins/init.lua). Local checkout lives at ~/Repos/avante-claude.
--
-- Provider: Claude Code over ACP. This reuses the `claude` CLI's own login,
-- so no ANTHROPIC_API_KEY is required. Switch `provider` to "claude" and
-- export ANTHROPIC_API_KEY if you'd rather hit the API directly.

---@type avante.Config
return {
	provider = "claude-code",
	mode = "agentic",
	instructions_file = "avante.md",

	acp_providers = {
		["claude-code"] = {
			command = "claude-agent-acp",
			env = {
				NODE_NO_WARNINGS = "1",
				ACP_PATH_TO_CLAUDE_CODE_EXECUTABLE = vim.fn.exepath("claude"),
				ACP_PERMISSION_MODE = "bypassPermissions",
			},
		},
	},

	-- Direct-API fallback (only used if provider = "claude")
	providers = {
		claude = {
			endpoint = "https://api.anthropic.com",
			model = "claude-sonnet-4-20250514",
			timeout = 30000,
			extra_request_body = { temperature = 0.75, max_tokens = 20480 },
		},
	},

	selector = { provider = "telescope" },
	windows = { width = 35 },
}
