---@class BufferHistoryOnAttachHandler
local OnAttachHandler = {}

---@param self BufferHistory
---@return boolean is_success true if successful on_attach
function OnAttachHandler:on_attach()
	-- This is the function that handles entering a new file - maybe the most important of all
	--
	-- Structure
	--
	-- 1. Validate inputs by creating the new entry object
	-- Get the new bufnr and then the filepath, then create and validate the entry
	--
	-- 2. Validate against dups using validate_relative
	--
	-- 3. If all good, append it
	--
	-- 4. TODO Future logic for pruning


	if self.debug then vim.print("[on_attach] entered buffer with number: " .. vim.api.nvim_get_current_buf()) end

	if self.is_viewing then
		if self.debug then vim.print("[on_attach] left due to viewing") end
		self.is_viewing = false
		return false
	end

	local new_bufnr = vim.api.nvim_get_current_buf()
	local new_filepath = Get_filepath_from_bufnr(new_bufnr)
	local new_is_pinned = false -- default

	local new_entry = self.utils.new_entry(self, new_is_pinned, new_filepath, new_bufnr)

	if new_entry == nil then
		if self.debug then vim.print("Invalid buffer, skipping...") end
		return false
	end

	local is_valid = new_entry.validator.validate(new_entry, self)
	local is_valid_rel = new_entry.validator.validate_relative(new_entry, self)

	-- Debug output
	if not is_valid or not is_valid_rel then
		if self.debug then vim.print("[on_attach] new buffer with number " .. new_bufnr .. " and filepath: " .. new_filepath .. " is not valid") end
		if not is_valid and self.debug then vim.print("not valid") end
		if not is_valid_rel and self.debug then vim.print("not valid_rel") end
		return false
	end

	self.utils.append(self, new_entry)
	self.validator.validate(self)

	return true
end

return OnAttachHandler
