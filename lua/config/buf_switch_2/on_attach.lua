---@class BufferHistoryOnAttachHandler
local OnAttachHandler = {}

---@param self BufferHistory
---@param bypass? boolean
---@return boolean is_success true if successful on_attach
function OnAttachHandler:on_attach(bypass)
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


	if self.is_viewing and not bypass then
		if self.debug then vim.print("[on_attach] left due to viewing") end
		self.is_viewing = false
		return false
	end

	if self.paused and not bypass then

		-- This bit of logic just makes sure that when we are on paused mode, and we
		-- enter a file that is already inside our tree, then when we tab around,
		-- the plugin recognises that this item is in the tree and sets the pointer to the
		-- appropriate buffer.

		if self.debug then vim.print("[on_attach] left due to paused") end
		-- Check if buffer number is in current history
		local new_entry_unsafe = self.utils.new_entry(self) -- Warning - no checks or validation here

		if new_entry_unsafe == nil then -- If we can't find it just assume bad buffer and its not connetained
			self.is_outside = true
			return false
		end

		local idx_matches = self.validator.contains(self, new_entry_unsafe, false)
		if idx_matches ~= nil then -- If we find it, then we are not outside
			self.current_index = idx_matches[#idx_matches]
			self.is_outside = false
			return false
		end

		self.is_outside = true

		return false
	end

	if self.debug and bypass then vim.notify"Bypassing block paused and viewing" end
	if self.debug then vim.print("[on_attach] entered buffer with number: " .. vim.api.nvim_get_current_buf()) end

	local new_bufnr = vim.api.nvim_get_current_buf()
	local new_filepath = Get_filepath_from_bufnr(new_bufnr)
	local new_is_pinned = false -- default

	local contains_matching = self.utils.get_matching_entry_idx(self, new_filepath, new_bufnr, nil, false)
	if contains_matching ~= nil then
		local index = contains_matching[#contains_matching]
		local old_entry = self.history[index]
		self.current_index = old_entry.level
		return false
	end

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
