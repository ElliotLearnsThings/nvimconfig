---@class BufferEntryValidator
local BufferEntryValidator = {}

---@class BufferHistoryValidator
local BufferHistoryValidator = {}

---@param self BufferEntry
---@param history BufferHistory
---@return boolean is_valid_relative
--- Check self against most recent input
--- We are checking if the new file is valid relative to the last file added
--- This should only be called when history.current_index == #history.history
function BufferEntryValidator:validate_relative(history)

	local history_length = #history.history

	local is_valid_call = history.current_index == history_length
	if not is_valid_call then
		return true
	end

	-- Given that the call is valid, then we must check if this new entry is valid

	if history_length < 1 then
		-- Cannot check relative if it is empty
		return true
	end

	local previous_entry = history.history[history_length]
	if self.filepath == previous_entry.filepath then
		return false
	elseif self.bufnr == previous_entry.bufnr then
		return false
	end
	return true
end

---@param self BufferHistory
---@param other_entry BufferEntry
---@param exclude_pinned boolean should exclude pinned from match
---@return integer[]? idx returns idx of all matches if it does contain, otherwise nil
function BufferHistoryValidator:contains(other_entry, exclude_pinned)
	return self.utils.get_matching_entry_idx(self, other_entry.filepath, other_entry.bufnr, nil, exclude_pinned)
end

---@param self BufferEntry
---@param history BufferHistory
function BufferEntryValidator:validate(history)
	-- Validate the entry for checking for spesific features
	local is_valid_filepath = vim.fn.filereadable(self.filepath) == 1
	local is_disallowed_filepath = self.validator.check_disallowed_buffers(self)

	if is_disallowed_filepath then
		if history.debug then vim.print"is_disallowed_filepath: false" end
		return false
	end

	local is_valid_bufnr = vim.fn.bufexists(self.bufnr) == 1

	-- Fix is pinned
	if not self.is_pinned then self.is_pinned = false end
	local is_valid_level = self.level <= history.utils.get_max_level(history) + 1
	if history.debug then
		vim.print(vim.inspect{is_valid_bufnr, is_valid_filepath, is_valid_level, is_disallowed_filepath})
	end

	-- Filepath can become invalde due to filename changes
	if not is_valid_filepath and is_valid_bufnr and not is_disallowed_filepath and is_valid_level then
		vim.print("[BufferEntry/validate] reloading file!")
		local filepath = Get_filepath_from_bufnr(self.bufnr)
		assert(filepath)
		self.filepath = filepath
		return true
	end

	if is_valid_bufnr and is_valid_filepath and is_valid_level and not is_disallowed_filepath then
		return true
	end
	-- Otherwise if any of the conditions, return fail
	if history.debug then
		vim.print(vim.inspect{is_valid_bufnr, is_valid_filepath, is_valid_level, is_disallowed_filepath})
	end
	return false
end

---@param self BufferEntry
---@return boolean is_valid
function BufferEntryValidator:check_disallowed_buffers()
	-- Check to see if the filepath is an invalid buffer
	-- Filter special buffers

	local buf_type
	local ft

	if pcall(function () local _ = vim.bo[self.bufnr] end) then
		buf_type = vim.bo[self.bufnr].buftype
		ft = vim.bo[self.bufnr].filetype
	else
		buf_type = ""
		ft = "nofile" -- Invalidate if the buffer number is invalid
	end


	if buf_type == "nofile" then -- Allow normal buffers and 'nofile' buffers
		return true
	end

	--if not vim.bo[self.bufnr].buflisted then -- Skip unlisted buffers
		--return true
	--end

	-- Add more specific filters if needed (like oil, telescope, etc.)
	if ft == "oil" or (self.filepath and self.filepath:match("^oil://")) or ft:match("harpoon") or ft:match("TelescopePrompt") then
		return true
	end
	return false
end

---@param self BufferHistory 
---@return nil
function BufferHistoryValidator:validate()

	-- Find buffer indexs that are 
	-- 1. dupes
	-- 2. no longer valid

	local idxs_dups = {}
	local previous_entry_dups
	local current_entry_dups

	-- Find dupes
	for idx, entry in ipairs(self.history) do
		previous_entry_dups = current_entry_dups or nil
		current_entry_dups = entry

		if previous_entry_dups ~= nil then
			if previous_entry_dups.filepath == current_entry_dups.filepath then
				assert((idx - 1) > 0)
				assert((idx - 1) < #self.history)
				assert((idx) > 0)
				assert((idx) <= #self.history)
				if not previous_entry_dups.is_pinned then
					table.insert(idxs_dups, idx - 1) -- (idx of the previous entry)
				elseif not current_entry_dups.is_pinned then
					table.insert(idxs_dups, idx) -- (idx of the previous entry)
				end
			end
		end
	end

	-- Remove dups 
	for _, idx in ipairs(idxs_dups) do -- Just to be clear this is a list of idx
		self.utils.remove(self, nil, nil, idx)
	end

	-- local idxs_is_valid

	-- Find invalid
	-- for idx, entry in ipairs(self.history) do
		-- local is_valid = entry.validator.validate(entry, self) -- We don't care about pins when checking if valid
		-- if is_valid then
			-- table.insert(idxs_is_valid, idx) -- (idx of the previous entry)
		-- end
	-- end

	-- Remove is_valid
	--for _, idx in ipairs(idxs_is_valid) do -- Just to be clear this is a list of idx
		--self.utils.remove(self, nil, nil, idx)
	--end

	assert(self.current_index >= 0)
	assert(self.current_index <= #self.history)
end

return {
	BufferEntryValidator = BufferEntryValidator,
	BufferHistoryValidator = BufferHistoryValidator,
}
