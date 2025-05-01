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
---@param target_input integer
---@return nil
function BufferHistoryUtils:delete_at_target(target_input)
	local target = #self.history - target_input + 1
	local init_index = self.current_index

	if #self.history < target or #self.history <= 1 or init_index == target then
		return
	end

	table.remove(self.history, target)
	self.utils.update_ui(self)
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

local function reversedipairsiter(t, i)
    i = i - 1
    if i ~= 0 then
        return i, t[i]
    end
end
local function reversedipairs(t)
    return reversedipairsiter, t, #t + 1
end

function BufferHistoryUtils:fix_levels()
  -- 1. Collect unique existing levels
  local unique_levels_set = {}
  local unique_levels_list = {}

  for _, entry in ipairs(self.history) do
    if entry.level ~= nil and not unique_levels_set[entry.level] then
      unique_levels_set[entry.level] = true
      table.insert(unique_levels_list, entry.level)
    end
  end

  -- Handle the case where there are no levels to fix
  if #unique_levels_list == 0 then
    -- vim.notify("No levels found in history to fix.", vim.log.levels.INFO)
    return
  end

  -- 2. Sort the unique levels numerically
  table.sort(unique_levels_list)

  -- Optional: Notify about the sorted unique levels found
  -- vim.notify("Sorted unique levels: " .. vim.inspect(unique_levels_list), vim.log.levels.DEBUG)

  -- 3. Create the mapping from old level to new consecutive level
  local level_map = {}
  for i, old_level in ipairs(unique_levels_list) do
    level_map[old_level] = i -- Assign new level based on sorted order (1, 2, 3...)
  end

  -- Optional: Notify about the created level map
  -- vim.notify("Level map created: " .. vim.inspect(level_map), vim.log.levels.DEBUG)

  -- 4. Update the history entries with the new levels
  for _, entry in ipairs(self.history) do
    if entry.level ~= nil then
      local new_level = level_map[entry.level]
      if new_level ~= nil then
        entry.level = new_level
      else
        -- This case should ideally not happen if logic is correct,
        -- but good for robustness/debugging.
        vim.notify(
          "Warning: Could not find mapping for level " .. tostring(entry.level),
          vim.log.levels.WARN
        )
      end
    end
  end
end

---@param self BufferHistory
---@return nil
function BufferHistoryUtils:update_ui()
	-- We add a list of all entries to vim.o.winbar
	-- Format the string as such
	-- If buffer ~= self.current_index then
	-- [ 1 ] [ 2 ] [ 3 ] etc..
	-- If buffer == self.current_index then
	-- [ filename ]
	-- Expected:
	-- [ 1 ] [ 2 ] [ 3 ] [ filename ] [ 5 ] [ 6 ] ..

	local bufnr = vim.api.nvim_get_current_buf()
	local winbar = ""
	local max_level = self.utils.get_max_level(self)

	-- Loop backwards
	for i, entry in reversedipairs(self.history) do
		if entry.level == self.current_index then
			local filepath = entry.filepath
			if filepath == nil then
				filepath = vim.api.nvim_buf_get_name(bufnr)
			end
			if filepath == "" then
				filepath = "[No Name]"
			end

			-- If oil buffer show Oil
			if filepath:find("oil://") then
				filepath = "Oil"
			end

			-- If file is not a file then show the buffer name
			if filepath:find("No Name") then
				filepath = vim.api.nvim_buf_get_name(bufnr)
			end

			-- Find last / and remove everything before it
			local last_slash = filepath:match(".*()/")
			local filename = filepath
			if last_slash then
				filename = filepath:sub(last_slash + 1)
			end

			winbar = winbar .. string.format("[ %s ] ", filename)
		else

			--vim.notify(vim.inspect{
				--max_level = max_level,
				--calculated_level = max_level - entry.level + 1,
				--entry_level = entry.level + 1,
				--iter = i,
			--})

			winbar = winbar .. string.format("[ %d ] ", max_level - entry.level + 1)
		end
	end

	vim.o.winbar = winbar
end

---@param self BufferHistory
---@param entry BufferEntry
---@return nil
function BufferHistoryUtils:append(entry)

	-- Check if dup in self.history
	local idx_matches = self.utils.get_matching_entry_idx(self, entry.filepath, entry.bufnr, nil, false)
	if idx_matches ~= nil then
		for _, idx in ipairs(idx_matches) do
			table.remove(self.history, idx)
		end
	end

	table.insert(self.history, entry)
	self.current_index = #self.history
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
		if i < self.current_index and self.current_index > 0 then -- This should fix the -1 index bug
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
				vim.notify"not pinned error"
				assert(not entry.is_pinned)
			end
			if idx == index then
				table.insert(inds, idx)
				goto continue
			end
			if filepath == entry.filepath then
				table.insert(inds, idx)
				goto continue
			end
			if bufnr == entry.bufnr then
				table.insert(inds, idx)
				goto continue
			end
			::continue::
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

---@param self BufferHistory
---@return nil
function BufferHistoryUtils:reset ()
	self.history = {}
	self.current_index = 0
	vim.notify"Reset buffer history"
end

---@param self BufferHistory
---@return nil
function BufferHistoryUtils:toggle_pause()
	if not self.paused and #self.history == 0 then
		vim.notify"Warn: your buffer history is empty"
	end

	self.paused = not self.paused
	if self.paused then
		vim.print("Paused buffer addition")
	else
		vim.print("Unpaused buffer addition")
	end
end

return BufferHistoryUtils
