-- Persistent on/off switch for the avante.nvim plugin.
--
-- The state lives in a file under stdpath("state") so it survives restarts.
-- lua/plugins/avante.lua reads it for lazy.nvim's `enabled` field, which means
-- a flip only takes effect on the next nvim start: lazy decides what is in the
-- spec while it loads, and there is no reliable way to tear avante back down
-- once its plugins, autocmds and mappings are in place.

local M = {}

local state_file = vim.fn.stdpath("state") .. "/avante_enabled"

-- Defaults to enabled when the file is missing or unreadable.
function M.is_enabled()
	local f = io.open(state_file, "r")
	if not f then
		return true
	end
	local contents = f:read("*l")
	f:close()
	return vim.trim(contents or "") ~= "0"
end

-- Persist the new state and say whether this session already matches it, so a
-- pointless restart is not implied when nothing would change.
function M.set(enabled)
	vim.fn.mkdir(vim.fn.fnamemodify(state_file, ":h"), "p")
	local f = io.open(state_file, "w")
	if not f then
		vim.notify("avante toggle: cannot write " .. state_file, vim.log.levels.ERROR)
		return
	end
	f:write(enabled and "1\n" or "0\n")
	f:close()

	local loaded = require("lazy.core.config").plugins["avante.nvim"] ~= nil
	local state = enabled and "enabled" or "disabled"
	if enabled == loaded then
		vim.notify("avante " .. state .. " (already active this session)", vim.log.levels.INFO)
	else
		vim.notify("avante " .. state .. " — restart nvim to apply", vim.log.levels.WARN)
	end
end

-- Flip the persisted state; what is running this session is left untouched.
function M.toggle()
	M.set(not M.is_enabled())
end

vim.api.nvim_create_user_command("AvanteToggle", function()
	M.toggle()
end, { desc = "Toggle avante.nvim on/off persistently (needs restart)" })

vim.api.nvim_create_user_command("AvanteEnable", function()
	M.set(true)
end, { desc = "Enable avante.nvim persistently (needs restart)" })

vim.api.nvim_create_user_command("AvanteDisable", function()
	M.set(false)
end, { desc = "Disable avante.nvim persistently (needs restart)" })

vim.keymap.set("n", "<leader>ta", M.toggle, { desc = "Toggle avante.nvim (persistent)" })

return M
