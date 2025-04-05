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

return get_env_data()
