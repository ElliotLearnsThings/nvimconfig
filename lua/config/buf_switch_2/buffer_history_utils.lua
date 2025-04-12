---@class BufferHistoryUtils
local BufferHistoryUtils = {}

local buffer_entry = require("config.buf_switch_2.buffer_entries")

---@param self BufferHistory history 
---@return integer max_level Highest level in the current history
function BufferHistoryUtils:get_max_level()
	if #self.history == 0 then return 0 end

	local max_level = 0
	for _, entry in ipairs(self.history) do
		assert(entry.level ~= nil)
		if entry.level > max_level then
			max_level = entry.level
		end
	end

	if #self.history > 0 then assert(max_level > 0) end
	return max_level
end

---@param self BufferHistory
---@param is_pinned? boolean
---@param filepath? string
---@param bufnr? integer
---@return BufferEntry? new_entry Only if it passed validation
function BufferHistoryUtils:new_entry(is_pinned, filepath, bufnr)
	return buffer_entry.new(self, {
		is_pinned = is_pinned or false,
		filepath = filepath or nil,
		bufnr = bufnr or nil
	})
end

---@param self BufferHistory
---@param entry BufferEntry
---@return nil
function BufferHistoryUtils:append(entry)
	table.insert(self.history, entry)
	self.current_index = self.current_index + 1
end

---@param self BufferHistory
---@param filepath? string
---@param bufnr? integer
---@param index? integer
---@param exculde_pinned? boolean exculde pinned entrys from removal
function BufferHistoryUtils:remove(filepath, bufnr, index, exculde_pinned)
	local inds = self.utils.get_matching_entry_idx(self, filepath, bufnr, index, exculde_pinned)

	if not inds then
		return
	end

	for i in ipairs(inds) do
		table.remove(self.history, i)
		if i < self.current_index then
			self.current_index = self.current_index - 1
		end
	end

	assert(self.current_index >= 0)
end


---Function that finds all maching ids of buffer entries
---@param self BufferHistory
---@param filepath? string
---@param bufnr? integer
---@param index? integer
---@param exculde_pinned? boolean
---@return integer[]? idx of matching entries or nil if none found
function BufferHistoryUtils:get_matching_entry_idx(filepath, bufnr, index, exculde_pinned)

	-- A bit annoying boolean logic but heres a description...
	-- exculde_pinned is true then
	-- if not entry.exculde_pinned then  -> (~exculde_pinned | ~entry.is_pinned) true if is_pinned is false
	--
	-- exculde_pinned is false then -> (~exculde_pinned | ~entry.is_pinned) always true
	-- doesnt matter always true

	local inds = {}
	exculde_pinned = exculde_pinned or false

	for idx, entry in ipairs(self.history) do
		if (not exculde_pinned) or (not entry.is_pinned) then
			if exculde_pinned then
				assert(not entry.is_pinned)
			end
			if idx == index then
				table.insert(inds, idx)
			end
			if filepath == entry.filepath then
				table.insert(inds, idx)
			end
			if bufnr == entry.bufnr then
				table.insert(inds, idx)
			end
		end
	end

	assert(#inds >= 0)
	assert(#inds <= #self.history)
	if #inds > 0 then
		return inds
	else
		return nil
	end
end

---@param self BufferHistory
---@return nil
function BufferHistoryUtils:clear ()
	self.history = {}
	self.current_index = 0
	self.on_attach.on_attach(self) -- reattach the buffer
	vim.notify"Cleared buffer history"
end

return BufferHistoryUtils
