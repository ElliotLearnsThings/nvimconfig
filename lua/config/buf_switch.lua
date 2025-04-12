--- NOTES
--- Add tree support for moving buffers around
--- Add harpoon mode (fixed anchors set with keybind)
--- Add Anchored buffers (buffers that can never be removed)
--- Add global state for the buffer history

---@class bufferEntry
---@field bufnr number Buffer number
---@field filepath string Buffer file path

---@class bufferHistory
---@field buffer_history bufferEntry[] List of entries with {bufnr=number, filepath=string}
---@field current integer current buffer index
---@field debug boolean debug mode
---@field is_load boolean flag for initial load
---@field is_viewing boolean is viewing previous
---@field last_save_time number timestamp of last save
---@field mode string current mode (flat or tree)
local M = {}

DEBUG_TREE_MODE = false

---@class bufferEntryMovement Entry with a level
---@field Entry bufferEntry The entry
---@field level integer The level of the entry in the tree

---@class BufferTreeHistory stores the history of movement between buffers
---@field buffer_tree_history bufferEntryMovement[]	list of entries 
---@field max_level integer The max level of the entry in the tree
local buffer_tree_history = {}

function buffer_tree_history.new()
	local this = {
		buffer_tree_history = {},
		max_level = 0,
	}

	return setmetatable(this, {
		__index = buffer_tree_history,
		__tostring = function(self)
			return "BufferTreeHistory: " .. vim.inspect(self.buffer_tree_history)
		end
	})
end

BUFFER_TREE_HISTORY = buffer_tree_history.new()
DEBUG_TREE_HISTORY = false

--- Just remove any duplicated next to each other
---@param self BufferTreeHistory
---@return nil
function buffer_tree_history:validate()
    local prev_entry = nil
    local cur_entry = nil
    -- Loop iterates through the list inside the BUFFER_TREE_HISTORY object
    for _, entry in ipairs(self.buffer_tree_history) do  -- Line ~49/50
         prev_entry = cur_entry
         cur_entry = entry
         if prev_entry == nil then
             goto continue
         end
         -- Compare filepaths of the contained Entry tables
         if prev_entry.Entry.filepath == cur_entry.Entry.filepath then -- Likely Line 55 based on structure
             -- *** Potential Problem Area ***
             table.remove(self.buffer_tree_history, cur_entry - 1) -- Line ~57
         end
         ::continue::
    end
end
--- We are expecting that the last entry in the buffer tree is the most recent, the prune flagger if you will
---@param self BufferTreeHistory
---@return boolean True if it was pruned, false otherwise
function BUFFER_TREE_HISTORY:prune()
	-- Prune the buffer tree history to remove entries that are no longer valid
	--
	-- This will not always prune, but check if it should and then do if it should
	-- We check for prune if the follow condition is true:
	-- 1. The buffer tree history is not empty
	-- 2. The max level is greater than 0
	-- 3. The max level is greater than the current buffer history size
	--
	-- We then check if the new buffer in the movement is one level greater than the previous movement
	-- if it is, we need to prune the history, and set the new max level
	-- First checks
	if #self.buffer_tree_history == 0 or #self.buffer_tree_history == 1 then
		if DEBUG_TREE_HISTORY then vim.print("[BUFFER_TREE_HISTORY] #self.buffer_tree_history == 0 or 1, did not proon", vim.log.levels.INFO) end
		return false
	end
	if self.max_level == 0 or self.max_level == 1 then
		if DEBUG_TREE_HISTORY then vim.print("[BUFFER_TREE_HISTORY] self.max_level == 0 or self.max_level == 1, did not proon", vim.log.levels.INFO) end
		return false
	end
	if self.max_level >= #self.buffer_tree_history then
		if DEBUG_TREE_HISTORY then vim.print("[BUFFER_TREE_HISTORY] self.max_level >= #self.buffer_tree_history, did not proon", vim.log.levels.INFO) end
		return false
	end

	-- If we make it here, check if we need to prune
	local current_level = self.buffer_tree_history[#self.buffer_tree_history].level
	local previous_level = self.buffer_tree_history[#self.buffer_tree_history - 1].level

	local last_entry

	local delta_level = current_level - previous_level

	if DEBUG_TREE_HISTORY then vim.print("[BUFFER_TREE_HISTORY] delta_level: " .. delta_level, vim.log.levels.INFO) end

	if delta_level > 1 then
		--if DEBUG_TREE_HISTORY then 
		if DEBUG_TREE_HISTORY then vim.print("[BUFFER_TREE_HISTORY] PRUNING!", vim.log.levels.INFO) end
		if DEBUG_TREE_HISTORY then vim.print("[BUFFER_TREE_HISTORY] object before prune") end
		--end

		-- Pop out the last entry
		last_entry = table.remove(self.buffer_tree_history)
		current_level = previous_level + 1
		if DEBUG_TREE_HISTORY then vim.print("[BUFFER_TREE_HISTORY] current_level:" .. current_level, vim.log.levels.INFO) end

		-- We need to prune the history
		-- We need to remove all entries that are greater than the current level
		for i = #self.buffer_tree_history, 1, -1 do
			local entry = self.buffer_tree_history[i]
			if entry.level >= current_level then
				if DEBUG_TREE_HISTORY then vim.print("found matching entry with current_level:" .. current_level) end
				table.remove(self.buffer_tree_history, i)
			end
		end
		self.max_level = current_level
	else
		return false
	end

	-- Now insert the new entry
	local new_entry = {
		Entry = last_entry.Entry,
		level = current_level,
	}
	table.insert(self.buffer_tree_history, new_entry)
	if DEBUG_TREE_HISTORY then vim.print("Final object after pruning:" .. vim.inspect(self)) end
	return true
end

---@enum MODES
local MODES = {
	FLAT = "flat",
	TREE = "tree"
}

--- Create a new buffer history object
--- @param mode MODES The mode that it will use
--- @param debug boolean whether to enable debug mode
function M.new(mode, debug)
	local bufnr = vim.api.nvim_get_current_buf()

	local valid_mode = false

	-- Validate input mode
	for _, cur_mode in pairs(MODES) do
		if mode == cur_mode then
			valid_mode = true
			break
		end
	end

	if not valid_mode then
		vim.notify("Invalid mode: " .. mode .. ". Defaulting to FLAT mode.", vim.log.levels.WARN)
		mode = MODES.FLAT
	else
		vim.notify("Buffer history initialized with mode: " .. mode, vim.log.levels.INFO)
	end


	if bufnr == -1 then
		vim.notify("Error setting up buffer history", vim.log.levels.ERROR)
		return
	end

	local buffer_history = {}
	local current_index = 0

	if debug then
		vim.notify("Buffer history initialized with buffer number: " .. bufnr)
		vim.notify("current_index: " .. current_index)
		vim.notify("buffer_history: " .. vim.inspect(buffer_history))
	end

	--- return the metatable
	local this = {
		buffer_history = buffer_history,
		current = current_index,
		debug = debug,
		is_load = true,
		is_viewing = false,
		mode = mode or MODES.TREE, -- Need to make a switcher for the setup later
	}

	return setmetatable(this, {
		__index = M,
		__tostring = function(self)
			return "BufferHistory: " .. vim.inspect(self.buffer_history)
		end
	})
end

--- Removes the first matching entry from buffer_history by bufnr or filepath.
---@param self bufferHistory
---@param input_bufnr? number Buffer number to remove.
---@param input_filepath? string Filepath to remove.
---@return boolean True if an entry was removed, false otherwise.
function M:remove_entry(input_bufnr, input_filepath)
    local has_filepath = not (input_filepath == nil or input_filepath == "")
    local has_bufnr = not (input_bufnr == nil)

    if not has_filepath and not has_bufnr then
        if self.debug then
            vim.notify("[remove_entry] WARNING: Tried to remove without valid bufnr or filepath", vim.log.levels.WARN)
        end
        return false
    end

    local idx_to_remove = nil
    -- Iterate backwards for safer removal while iterating
    for i = #self.buffer_history, 1, -1 do
        local entry = self.buffer_history[i]
        local match = false

        -- Prioritize bufnr if provided
        if has_bufnr and entry.bufnr == input_bufnr then
            match = true
        -- Fallback to filepath if bufnr not provided or didn't match
        elseif has_filepath and not has_bufnr and entry.filepath == input_filepath then
             match = true
        -- If both provided, check filepath only if bufnr matched (or if bufnr didn't exist in entry)
         elseif has_bufnr and has_filepath and entry.bufnr == input_bufnr and entry.filepath == input_filepath then
              match = true
         elseif has_filepath and entry.filepath == input_filepath and entry.bufnr == nil then -- Match filepath if entry has no bufnr
              match = true
        end

        if match then
            idx_to_remove = i
            break -- Remove only the first match found (from the end)
        end
    end

    if idx_to_remove then
        local removed = table.remove(self.buffer_history, idx_to_remove)
        if self.debug then
            vim.notify("[remove_entry] Removed entry at index " .. idx_to_remove .. ": bufnr=" .. (removed.bufnr or "nil") .. ", filepath=" .. (removed.filepath or "nil"), vim.log.levels.INFO)
        end

        -- Adjust the 'current' pointer correctly
        if #self.buffer_history == 0 then
             self.current = 0 -- History is now empty
             if self.debug then vim.notify("[remove_entry] History empty, current set to 0.", vim.log.levels.DEBUG) end
        elseif idx_to_remove < self.current then
             -- If removed item was before current, decrement current
             self.current = self.current - 1
             if self.debug then vim.notify("[remove_entry] Removed before current, current adjusted to: " .. self.current, vim.log.levels.DEBUG) end
        elseif idx_to_remove == self.current then
             -- If removed item *was* current, clamp current to the new end of history
             -- or stay at current-1 if that makes sense (depending on desired behavior after deleting current)
             -- Clamping to end is usually safer unless implementing specific nav logic.
             self.current = math.min(self.current, #self.buffer_history)
             -- If the list wasn't empty before removal, current should be at least 1
             self.current = math.max(1, self.current)
              if self.debug then vim.notify("[remove_entry] Removed current item, current clamped/adjusted to: " .. self.current, vim.log.levels.DEBUG) end
        else -- idx_to_remove > self.current
             -- If removed item was after current, current pointer is unaffected relative to remaining items. No change needed.
             if self.debug then vim.notify("[remove_entry] Removed after current, current ("..self.current..") remains unchanged.", vim.log.levels.DEBUG) end
        end
        -- Ensure current doesn't exceed bounds after adjustment
        self.current = math.min(self.current, #self.buffer_history)
        if #self.buffer_history > 0 then self.current = math.max(1, self.current) end

        return true
    else
        if self.debug then
             vim.notify("[remove_entry] Entry not found for bufnr=" .. (input_bufnr or "nil") .. ", filepath=" .. (input_filepath or "nil"), vim.log.levels.DEBUG)
        end
        return false
    end
end

function M:validate()
	-- Iterate backward through the buffer history
	local seen_paths = {}
	local seen_bufnrs = {}

	for idx = #self.buffer_history, 1, -1 do
		local entry = self.buffer_history[idx]
		local bufnr = entry.bufnr
		local filepath = entry.filepath

		-- For entries with bufnr, check buffer validity
		-- For entries without bufnr, consider valid if filepath exists
		local is_valid_entry

		if bufnr then
			-- If there's a buffer number, it needs to be valid
			is_valid_entry = bufnr ~= -1 and vim.api.nvim_buf_is_valid(bufnr)
		else
			-- If there's no buffer number, the entry is valid if filepath exists
			-- and is readable (we're more lenient on initial load)
			is_valid_entry = filepath and filepath ~= "" and vim.fn.filereadable(filepath) == 1
		end

		-- Check for duplicates
		local is_duplicate = false
		if filepath and filepath ~= "" then
			if seen_paths[filepath] then
				is_duplicate = true
			else
				seen_paths[filepath] = true
			end
		elseif bufnr then -- For buffers without filepaths (unnamed)
			if seen_bufnrs[bufnr] then
				is_duplicate = true
			else
				seen_bufnrs[bufnr] = true
			end
		end

		-- Remove invalid or duplicate entries
		if not is_valid_entry or is_duplicate then
			table.remove(self.buffer_history, idx)
		end
	end
end

--- Clears the buffer history and adds the current buffer.
---@param self bufferHistory
function M:clear()
	self.buffer_history = {}
	self.current = 0

	local current_buffer = vim.api.nvim_get_current_buf()
	if current_buffer ~= -1 and vim.api.nvim_buf_is_valid(current_buffer) then
		local current_filepath = vim.api.nvim_buf_get_name(current_buffer)
		local new_entry = {
			bufnr = current_buffer,
			filepath = current_filepath ~= "" and current_filepath or nil,
		}
		table.insert(self.buffer_history, new_entry)
		self.current = 1 -- History now has one item at index 1
		if self.debug then vim.notify("[clear] Buffer history cleared. Added current buffer: " .. current_buffer, vim.log.levels.INFO) end
	else
		if self.debug then vim.notify("[clear] Buffer history cleared. No valid current buffer to add.", vim.log.levels.INFO) end
	end
	-- No need to validate an empty or single-item list
end

--- Called on BufEnter to update the history based on the current mode.
---@param self bufferHistory
---@return nil
---
function M:on_attach()

    -- Initial load flag check
    if self.is_load then
        if self.debug then vim.notify("[on_attach] Skipping update on initial load.", vim.log.levels.DEBUG) end
        self.is_load = false
        -- Optionally, validate right after load if needed
        -- self:validate()
        return
    end

    -- Get current buffer info
    local bufnr = vim.api.nvim_get_current_buf()
    if bufnr == -1 or not vim.api.nvim_buf_is_valid(bufnr) then
        if self.debug then vim.notify("[on_attach] Invalid buffer number: " .. bufnr, vim.log.levels.WARN) end
        return
    end
    local filepath = vim.api.nvim_buf_get_name(bufnr)
    local effective_filepath = filepath ~= "" and filepath or nil -- Use nil consistently

		local last_entry = self.buffer_history[#self.buffer_history]
		if filepath == last_entry.filepath and self.mode == MODES.TREE then
			-- We can skip
			return
		end

    -- Filter special buffers
    local buf_type = vim.bo[bufnr].buftype
    local ft = vim.bo[bufnr].filetype

    if buf_type ~= "" and buf_type ~= "nofile" then -- Allow normal buffers and 'nofile' buffers
        if self.debug then vim.notify("[on_attach] Skipping buffer " .. bufnr .. " due to buftype: " .. buf_type, vim.log.levels.DEBUG) end
        return
    end
    if not vim.bo[bufnr].buflisted then -- Skip unlisted buffers
         if self.debug then vim.notify("[on_attach] Skipping unlisted buffer " .. bufnr, vim.log.levels.DEBUG) end
         return
    end
    -- Add more specific filters if needed (like oil, telescope, etc.)
    if ft == "oil" or (effective_filepath and effective_filepath:match("^oil://")) or ft:match("harpoon") or ft:match("TelescopePrompt") then
        if self.debug then vim.notify("[on_attach] Skipping special filetype/path: " .. ft .. " / " .. (effective_filepath or ""), vim.log.levels.DEBUG) end
        return
    end

		--- TREE MODE EARLY PRUNE ---- 

		local did_prune = false
		-- Add entry to movement history and check if we need to prune
		if self.mode == MODES.TREE then
			if self.is_viewing then
				-- Check if it is in the self.buffer_history
				self.is_viewing = false
				for _, entry in ipairs(self.buffer_history) do
					if filepath == entry.filepath then
						return
					end
				end
			end

			local entry = {
					bufnr = bufnr,
					filepath = effective_filepath,
			}
			-- If the entry in inside the movement history, we need to update the maxlevel and set this entry's level to maxlevel
			-- Otherwise, we need to set the level to the same as the last matching entry
			local is_in_tree = false
			local current_level = -1
			for _, entry in ipairs(BUFFER_TREE_HISTORY.buffer_tree_history) do
				if entry.Entry.bufnr == bufnr or entry.Entry.filepath == filepath then
					is_in_tree = true
					current_level = entry.level
					break
				end
			end

			if is_in_tree and current_level > BUFFER_TREE_HISTORY.max_level then
				if DEBUG_TREE_HISTORY then vim.print("[on_attach] This should never happen! Warning, you might have found a bug! (is_in_tree and current_level > max_level), current:" .. current_level .. " max_level:" .. BUFFER_TREE_HISTORY.max_level, vim.log.levels.WARN) end
				BUFFER_TREE_HISTORY.max_level = current_level
			end

			if is_in_tree and current_level == nil then
				-- This should never happen
				if DEBUG_TREE_HISTORY then vim.print("[on_attach] This should never happen! Warning, you might have found a bug! (is_in_tree and current_level == nil)", vim.log.levels.WARN) end
				-- abort
				return
			end

			if is_in_tree then
				if self.debug then vim.notify("[on_attach] called not is_in_tree") end
				-- Add to end of the object, 
				local movement_entry = {
					Entry = entry,
					level = current_level,
				}
				table.insert(BUFFER_TREE_HISTORY.buffer_tree_history, movement_entry)
			end

			if not is_in_tree then
				if self.debug then vim.notify("[on_attach] called not is_in_tree") end
				-- Add to end of the object,
				local movement_entry = {
					Entry = entry,
					level = BUFFER_TREE_HISTORY.max_level + 1,
				}
				table.insert(BUFFER_TREE_HISTORY.buffer_tree_history, movement_entry)
				BUFFER_TREE_HISTORY.max_level = BUFFER_TREE_HISTORY.max_level + 1
			end

			if self.debug then vim.notify("BUFFER_TREE_HISTORY Before:" .. vim.inspect(BUFFER_TREE_HISTORY)) end

			did_prune = BUFFER_TREE_HISTORY:prune()
			-- if did_prune then vim.print("did prune") else vim.print("did not prune") end

			if self.debug and did_prune then
				vim.notify("BUFFER_TREE_HISTORY After prune:" .. vim.inspect(BUFFER_TREE_HISTORY))
			end
		end

    -- Check if this buffer is already the current logical buffer in history
    if self.current > 0 and self.current <= #self.buffer_history then
        local current_entry = self.buffer_history[self.current]
        if current_entry.bufnr == bufnr then
            if self.debug then vim.notify("[on_attach] Buffer " .. bufnr .. " is already the current logical entry (" .. self.current .. "). No update.", vim.log.levels.DEBUG) end
            return
        end
    end

    -- --- FLAT MODE ---
    if self.mode == MODES.FLAT then
        if self.is_viewing then -- Reset viewing flag if we entered a buffer during navigation
            if self.debug then vim.notify("[on_attach-Flat] Resetting is_viewing flag.", vim.log.levels.DEBUG) end
            self.is_viewing = false
            -- In flat mode, if viewing, the 'current' pointer might be somewhere in the middle.
            -- Standard flat behavior often moves the visited buffer to the end unless viewing.
            -- Decide if entering *any* buffer while viewing should move it to the end.
            -- For now, let's assume entering a buffer *ends* viewing mode, but doesn't reorder yet.
            -- The reordering happens if is_viewing was *false*.
            return -- Avoid reordering just because viewing ended. Reorder happens on next non-viewing entry.
        end

        local existing_idx = nil
        for i = #self.buffer_history, 1, -1 do -- Search backwards
            local entry = self.buffer_history[i]
            if entry.bufnr == bufnr or (effective_filepath and entry.filepath == effective_filepath) then
                existing_idx = i
                break
            end
        end

        local entry_to_add = { bufnr = bufnr, filepath = effective_filepath }

        if existing_idx then
            -- Buffer exists, remove from old position and add to end
            if self.debug then vim.notify("[on_attach-Flat] Buffer exists at index " .. existing_idx .. ". Moving to end.", vim.log.levels.DEBUG) end
            table.remove(self.buffer_history, existing_idx)
            table.insert(self.buffer_history, entry_to_add)
        else
            -- Buffer doesn't exist, add to end
            if self.debug then vim.notify("[on_attach-Flat] New buffer. Adding to end.", vim.log.levels.DEBUG) end
            table.insert(self.buffer_history, entry_to_add)
        end
        -- In flat mode, current always points to the end
        self.current = #self.buffer_history

        if self.debug then
            vim.notify("[on_attach-Flat] History updated. New size: " .. #self.buffer_history .. ". Current: " .. self.current, vim.log.levels.INFO)
            -- print("[on_attach-Flat] History: ", vim.inspect(self.buffer_history))
        end

    -- --- TREE MODE ---
    elseif self.mode == MODES.TREE then


			-- If we didn't prune, we need to check if the current buffer is in the history
			--
			--
			-- If it is, we put it at the end
			--
			--
			-- If it isn't, we need to update the buffer history object
			-- Then we need to add it to the end -> the only way we prune is if it is a new buffer
			--
			-- Finally validate self

			local entry = {
				bufnr = bufnr,
				filepath = effective_filepath,
			}

			-- if did_prune then vim.print("did prune") else vim.print("did not prune") end

			if not did_prune then
				local is_in_history = false
				for idx, entry in ipairs(self.buffer_history) do
					if entry.bufnr == bufnr then
						is_in_history = true
						break
					end
				end

				if is_in_history then
					if self.debug then
						vim.notify("[on_attach-Tree] Buffer " .. bufnr .. " already in history. No update needed.", vim.log.levels.DEBUG)
					end
					return
				else
					table.insert(self.buffer_history, entry)
					self.current = #self.buffer_history
					if self.debug then
						vim.notify("[on_attach-Tree] Buffer " .. bufnr .. " added to history. Current: " .. self.current, vim.log.levels.INFO)
					end
					return
				end
			else
				-- In this case, we did prune, meaning we need to check for every buffer in self.buffer_history
				-- If the bufferfilepath is not in the movement history, we need to remove it
				local new_buffer_history = {}
				-- vim.print("current buffer_history: " .. vim.inspect(self.buffer_history))
				for _, cur_entry in ipairs(self.buffer_history) do

					-- vim.print("Checking filepath: ".. cur_entry.filepath)

					local is_in_movement_history_fp = false

					for _, movement_entry in ipairs(BUFFER_TREE_HISTORY.buffer_tree_history) do
						if cur_entry.filepath == movement_entry.Entry.filepath then
							is_in_movement_history_fp = true
						end
					end

					-- if is_in_movement_history_fp then vim.print("is valid") else vim.print("is valid") end

					if is_in_movement_history_fp then
						table.insert(new_buffer_history, cur_entry)
					end
				end
				-- vim.print("final table: " .. vim.inspect(new_buffer_history))
				self.buffer_history = new_buffer_history
				self.current = #self.buffer_history

				-- Now we know that the new buffer will never be in the self.buffer_history , but if it is, warn that there is a bug and remove it
				local is_in_history = false
				for idx, entry in ipairs(self.buffer_history) do
					if entry.bufnr == bufnr then
						is_in_history = true
						break
					end
				end

				if is_in_history then
					self:validate() -- Double validate to assure that if there are any dups that they are removed.
					self:remove_entry(bufnr)
					if self.debug then
						vim.notify("[on_attach-Tree] This should never happen! You might have found a bug! Buffer " .. bufnr .. " already in history. Removing it.", vim.log.levels.DEBUG)
					end
				end

				-- Now we can add the new buffer to the end
				table.insert(self.buffer_history, entry)
				self.current = #self.buffer_history
			end
    end -- End Tree Mode

    -- Optional: Validate after updates, can be expensive
    self:validate()
		self.current = #self.buffer_history
end

function M:save_history()
	-- Save all object history to a file in the data directory
	local cwd = vim.fn.getcwd()
	-- Sanitize the cwd to create a valid filename
	local sanitized_cwd = cwd:gsub("/", "_"):gsub(":", "_")

	-- Ensure the directory exists
	local data_dir = vim.fn.stdpath("data") .. "/buffer_history"
	vim.fn.mkdir(data_dir, "p")

	local file_path = data_dir .. "/" .. sanitized_cwd .. "_buffer_history.json"
	local file = io.open(file_path, "w")

	if file then
		-- Filter out invalid buffers before saving and save with file paths
		local valid_entries = {}
		for _, entry in ipairs(self.buffer_history) do
			local bufnr = entry.bufnr
			local filepath = entry.filepath

			if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
				-- Update filepath if needed
				if not filepath or filepath == "" then
					filepath = vim.api.nvim_buf_get_name(bufnr)
				end

				table.insert(valid_entries, {
					bufnr = bufnr,
					filepath = filepath ~= "" and filepath or nil,
				})
			elseif filepath and filepath ~= "" and vim.fn.filereadable(filepath) == 1 then
				-- Keep entry if file exists even if buffer doesn't
				table.insert(valid_entries, {
					bufnr = nil,  -- Buffer no longer exists
					filepath = filepath,
				})
			end
		end

		local json = vim.json.encode(valid_entries)
		file:write(json)
		file:close()
		-- vim.notify("Buffer history saved to " .. file_path, vim.log.levels.INFO)
	else
		vim.notify("Error saving buffer history to " .. file_path, vim.log.levels.ERROR)
	end
end

function M:display_buffers()
	self:validate()
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local previewers = require("telescope.previewers")

	-- Format buffer entries
	local buffer_entries = {}

	if self.debug then
		vim.notify("Current buffer history: " .. vim.inspect(self.buffer_history))
	end

	-- Process entries in reverse order (newest first)
	for idx, entry in ipairs(self.buffer_history) do
		local bufnr = entry.bufnr
		local filepath = entry.filepath
		local display_name

		-- Check if buffer is valid
		local is_valid_buffer = bufnr and vim.api.nvim_buf_is_valid(bufnr)

		if is_valid_buffer then
			-- Use buffer info for display
			local name = vim.api.nvim_buf_get_name(bufnr)
			if name == "" then
				display_name = (idx) .. ": " .. bufnr .. " - [Unnamed buffer]"
			else
				display_name = (idx) .. ": " .. bufnr .. " - " .. vim.fn.fnamemodify(name, ":~:.")
			end
		elseif filepath and filepath ~= "" then
			-- Use filepath for display (buffer doesn't exist yet)
			display_name = (idx) .. ": ⟳ " .. vim.fn.fnamemodify(filepath, ":~:.")

			-- Try to find if file exists
			if vim.fn.filereadable(filepath) ~= 1 then
				display_name = (idx) .. ": ! " .. display_name -- Mark files that don't exist
			end
		else
			-- Skip completely invalid entries
			goto continue
		end

		table.insert(buffer_entries, {
			index = idx,
			bufnr = bufnr,
			filepath = filepath,
			display = display_name,
			ordinal = display_name
		})


		::continue::
	end

	-- Log the entries if debugging
	if self.debug then
		vim.notify("Buffer entries for display: " .. vim.inspect(buffer_entries))
	end

	-- Handle case with no valid entries
	if #buffer_entries == 0 then
		vim.notify("No buffer history entries to display", vim.log.levels.INFO)
		return
	end

	-- Define a custom buffer previewer
	local buf_previewer = previewers.new_buffer_previewer({
		title = "Buffer Preview",
		get_buffer_by_name = function(_, entry)
			return entry.bufnr
		end,
		define_preview = function(self_n, entry, status)
			-- If valid buffer exists, use it
			if entry.bufnr and vim.api.nvim_buf_is_valid(entry.bufnr) then
				vim.api.nvim_win_set_buf(self_n.state.winid, entry.bufnr)
				return
			end

			-- If file exists but buffer doesn't, try to read file
			if entry.filepath and vim.fn.filereadable(entry.filepath) == 1 then
				local temp_bufnr = vim.api.nvim_create_buf(false, true)
				vim.api.nvim_win_set_buf(self_n.state.winid, temp_bufnr)

				-- Read the file content
				local lines = vim.fn.readfile(entry.filepath)
				vim.api.nvim_buf_set_lines(temp_bufnr, 0, -1, false, lines)

				-- Set filetype for syntax highlighting
				local ft = vim.filetype.match({ filename = entry.filepath })
				if ft then
					vim.api.nvim_buf_set_option(temp_bufnr, "filetype", ft)
				end

				return
			end

			-- Fall back to empty buffer if neither is available
			local empty_bufnr = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_win_set_buf(self_n.state.winid, empty_bufnr)
			vim.api.nvim_buf_set_lines(empty_bufnr, 0, -1, false, {"File no longer exists: " .. (entry.filepath or "")})
		end,
	})

	-- Create a custom picker
	pickers.new({}, {
		prompt_title = "Buffer History",
		finder = finders.new_table({
			results = buffer_entries,
			entry_maker = function(entry)
				return {
					value = entry,
					display = entry.display,
					ordinal = entry.ordinal,
					bufnr = entry.bufnr,
					filepath = entry.filepath,
					index = entry.index
				}
			end
		}),
		sorter = conf.generic_sorter({}),
		previewer = buf_previewer,
		attach_mappings = function(prompt_bufnr, map)
			-- Open buffer on selection
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()

				if self.debug then
					vim.notify("Selected entry: " .. vim.inspect(selection))
				end

				-- Case 1: Valid buffer exists
				if selection.bufnr and vim.api.nvim_buf_is_valid(selection.bufnr) then
					vim.api.nvim_set_current_buf(selection.bufnr)
					return
				end

				-- Case 2: Buffer doesn't exist but filepath does
				if selection.filepath and selection.filepath ~= "" then
					-- Check if file exists
					if vim.fn.filereadable(selection.filepath) == 1 then
						-- Open the file
						vim.cmd("edit " .. vim.fn.fnameescape(selection.filepath))

						-- Update buffer history entry with new buffer number
						local new_bufnr = vim.api.nvim_get_current_buf()
						self.buffer_history[selection.index].bufnr = new_bufnr
						return
					else
						vim.notify("File no longer exists: " .. selection.filepath, vim.log.levels.WARN)
					end
				end

				-- Case 3: No valid buffer or filepath
				vim.notify("Selected buffer is no longer valid", vim.log.levels.WARN)
			end)

			map("i", "<c-w>", function()
				-- This is a debug that just displays the selected entry

				local selection = action_state.get_selected_entry()

				vim.notify("Selected entry: " .. vim.inspect(selection), vim.log.levels.INFO)
				vim.notify("Current bufferHistory: " .. vim.inspect(self.buffer_history), vim.log.levels.INFO)

			end)
			-- Delete buffer from history on <c-d>
			map("i", "<c-d>", function()

				local selection = action_state.get_selected_entry()

				local real_index = selection.index

				if self.debug then
					vim.notify("Buffer history before: " .. vim.inspect(self.buffer_history))
					vim.notify("Buffer index selected: " .. vim.inspect(real_index))
				end

				local success = self:remove_entry(selection.bufnr, selection.filepath)

				if not success and self.debug then
					vim.notify("Failed to remove entry from buffer history", vim.log.levels.WARN)
					return
				elseif success and self.debug then
					vim.notify("Removed entry from buffer history", vim.log.levels.INFO)
				end

				-- Update current pointer if needed
				if self.current >= real_index then
					self.current = math.max(1, self.current - 1)
				end

				-- Refresh the picker
				local picker = action_state.get_current_picker(prompt_bufnr)
				picker:refresh(finders.new_table({
					results = self:_get_updated_buffer_entries(),
					entry_maker = function(entry)
						return {
							value = entry,
							display = entry.display,
							ordinal = entry.ordinal,
							bufnr = entry.bufnr,
							filepath = entry.filepath,
							index = entry.index
						}
					end
				}), { reset_prompt = false })
			end)


			-- Bring selected file to back <c-b>
			map("i", "<c-b>", function()
				local selection = action_state.get_selected_entry()
				local success = false

				if selection.bufnr and vim.api.nvim_buf_is_valid(selection.bufnr) then
					-- Move existing buffer to front
					success = self:move_to_back(selection.bufnr)
				elseif selection.filepath and vim.fn.filereadable(selection.filepath) == 1 then
					-- For entries with just filepath, move by filepath without opening
					success = self:move_to_back(nil, selection.filepath)
				else
					vim.notify("Selected buffer is no longer valid", vim.log.levels.WARN)
					return
				end

				if success then
					-- Refresh the picker to show updated order
					local picker = action_state.get_current_picker(prompt_bufnr)
					picker:refresh(finders.new_table({
						results = self:_get_updated_buffer_entries(),
						entry_maker = function(entry)
							return {
								value = entry,
								display = entry.display,
								ordinal = entry.ordinal,
								bufnr = entry.bufnr,
								filepath = entry.filepath,
								index = entry.index
							}
						end
					}), { reset_prompt = false })

					-- Notify user
					vim.notify("Item moved to back of history")
				end
			end)

			-- Bring selected file to front <c-f>
			map("i", "<c-f>", function()
				local selection = action_state.get_selected_entry()
				local success = false

				if selection.bufnr and vim.api.nvim_buf_is_valid(selection.bufnr) then
					-- Move existing buffer to front
					success = self:move_to_front(selection.bufnr)
				elseif selection.filepath and vim.fn.filereadable(selection.filepath) == 1 then
					-- For entries with just filepath, move by filepath without opening
					success = self:move_to_front(nil, selection.filepath)
				else
					vim.notify("Selected buffer is no longer valid", vim.log.levels.WARN)
					return
				end

				if success then
					-- Refresh the picker to show updated order
					local picker = action_state.get_current_picker(prompt_bufnr)
					picker:refresh(finders.new_table({
						results = self:_get_updated_buffer_entries(),
						entry_maker = function(entry)
							return {
								value = entry,
								display = entry.display,
								ordinal = entry.ordinal,
								bufnr = entry.bufnr,
								filepath = entry.filepath,
								index = entry.index
							}
						end
					}), { reset_prompt = false })

					-- Notify user
					vim.notify("Item moved to front of history")
				end
			end)


			map("i", "<c-s>", function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()

				if selection.bufnr and vim.api.nvim_buf_is_valid(selection.bufnr) then
					vim.cmd("split")
					vim.api.nvim_set_current_buf(selection.bufnr)
				elseif selection.filepath and vim.fn.filereadable(selection.filepath) == 1 then
					vim.cmd("split " .. vim.fn.fnameescape(selection.filepath))

					-- Update buffer history entry with new buffer number
					local new_bufnr = vim.api.nvim_get_current_buf()
					self.buffer_history[selection.index].bufnr = new_bufnr
				else
					vim.notify("Selected buffer is no longer valid", vim.log.levels.WARN)
				end
			end)

			-- Open file in vertical split on <c-v>
			map("i", "<c-v>", function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()

				if selection.bufnr and vim.api.nvim_buf_is_valid(selection.bufnr) then
					vim.cmd("vsplit")
					vim.api.nvim_set_current_buf(selection.bufnr)
				elseif selection.filepath and vim.fn.filereadable(selection.filepath) == 1 then
					vim.cmd("vsplit " .. vim.fn.fnameescape(selection.filepath))

					-- Update buffer history entry with new buffer number
					local new_bufnr = vim.api.nvim_get_current_buf()
					self.buffer_history[selection.index].bufnr = new_bufnr
				else
					vim.notify("Selected buffer is no longer valid", vim.log.levels.WARN)
				end
			end)

			return true
		end,
	}):find()
end

-- Helper method to get updated buffer entries after deletion
function M:_get_updated_buffer_entries()
	local buffer_entries = {}

	-- Process entries in reverse order (newest first) to match the display_buffers function
	for idx, entry in ipairs(self.buffer_history) do
		local bufnr = entry.bufnr
		local filepath = entry.filepath

		-- For buffer preview and display
		local is_valid_buffer = bufnr and bufnr ~= -1 and vim.api.nvim_buf_is_valid(bufnr)
		local display_name

		if is_valid_buffer then
			-- Use buffer info for display
			local name = vim.api.nvim_buf_get_name(bufnr)
			if name == "" then
				display_name = (idx) .. ": " .. bufnr .. " - [Unnamed buffer]"
			else
				display_name = (idx) .. ": " .. bufnr .. " - " .. vim.fn.fnamemodify(name, ":~:.")
			end
		elseif filepath and filepath ~= "" then
			-- Use filepath for display (buffer doesn't exist yet)
			display_name = (idx) .. ": ⟳ " .. vim.fn.fnamemodify(filepath, ":~:.")

			-- Try to find if file exists
			if vim.fn.filereadable(filepath) ~= 1 then
				display_name = (idx) .. ": ! " .. display_name
			end
		else
			-- Skip invalid entries
			goto continue
		end

		table.insert(buffer_entries, {
			index = idx,
			bufnr = bufnr,
			filepath = filepath,
			display = display_name,
			ordinal = display_name
		})

		::continue::
	end

	return buffer_entries
end

function M:get_buffer_at_index(index)
	-- Index is 1-based (F1 = first buffer, F2 = second buffer)
	-- Buffer history is ordered from oldest to newest
	-- So we need to convert from user index to actual array index

	local length = #self.buffer_history

	-- The user is thinking of buffers in reverse order (most recent = 1)
	local history_index = length - index + 1

	if history_index >= 1 and history_index <= length then
		self.current = history_index
		local entry = self.buffer_history[history_index]

		if self.debug then
			vim.notify("Going to buffer " .. index .. " (history index " .. history_index .. "): " .. vim.inspect(entry))
		end

		return entry
	else
		if self.debug then
			vim.notify("No buffer found at index " .. index .. " (history index would be " .. history_index .. ")")
		end
		return nil
	end
end

--- Moves the specified buffer to the back of the history
--- Can move by buffer number or filepath
--- @param target_bufnr? number Optional buffer number to move to back
--- @param target_filepath? string Optional filepath to move to back
function M:move_to_back(target_bufnr, target_filepath)
	-- Default to current buffer if no parameters provided
	if not target_bufnr and not target_filepath then
		target_bufnr = vim.api.nvim_get_current_buf()
	end


	if self.debug then
		vim.notify("Buffer history before: " .. vim.inspect(self.buffer_history))
	end
	-- Find buffer in history
	for i, entry in ipairs(self.buffer_history) do
		-- Match by buffer number if provided
		if target_bufnr and entry.bufnr == target_bufnr then
			local moved_entry = table.remove(self.buffer_history, i)
			table.insert(self.buffer_history, 1, moved_entry)

			-- Update current pointer if needed
			if self.current >= i then
				self.current = self.current - 1
			end

			if self.debug then
				vim.notify("Moved buffer " .. target_bufnr .. " to back of history")
			end

			return true
		end

		-- Match by filepath if buffer number not found or not provided
		if target_filepath and entry.filepath == target_filepath then
			local moved_entry = table.remove(self.buffer_history, i)
			table.insert(self.buffer_history, 1, moved_entry)

			-- Update current pointer if needed
			if self.current >= i then
				self.current = self.current - 1
			end

			if self.debug then
				vim.notify("Moved file " .. target_filepath .. " to back of history")
			end

			return true
		end
	end

	if self.debug then
		if target_bufnr then
			vim.notify("Buffer " .. target_bufnr .. " not found in history")
		elseif target_filepath then
			vim.notify("File " .. target_filepath .. " not found in history")
		end
	end

	return false
end



--- Moves the specified buffer to the front of the history
--- Can move by buffer number or filepath
--- @param target_bufnr? number Optional buffer number to move to front
--- @param target_filepath? string Optional filepath to move to front
function M:move_to_front(target_bufnr, target_filepath)
	-- Default to current buffer if no parameters provided
	if not target_bufnr or not target_filepath then
		target_bufnr = vim.api.nvim_get_current_buf()
	end

	-- Find buffer in history
	for i, entry in ipairs(self.buffer_history) do
		-- Match by buffer number if provided
		if target_bufnr and entry.bufnr == target_bufnr then
			local moved_entry = table.remove(self.buffer_history, i)
			table.insert(self.buffer_history, moved_entry)
			self.current = #self.buffer_history

			if self.debug then
				vim.notify("Moved buffer " .. target_bufnr .. " to front of history")
			end

			return true
		end

		-- Match by filepath if buffer number not found or not provided
		if target_filepath and entry.filepath == target_filepath then
			local moved_entry = table.remove(self.buffer_history, i)
			table.insert(self.buffer_history, moved_entry)
			self.current = #self.buffer_history

			if self.debug then
				vim.notify("Moved file " .. target_filepath .. " to front of history")
			end

			return true
		end
	end

	if self.debug then
		if target_bufnr then
			vim.notify("Buffer " .. target_bufnr .. " not found in history")
		elseif target_filepath then
			vim.notify("File " .. target_filepath .. " not found in history")
		end
	end

	return false
end

---@param self bufferHistory
---@param index number User-facing index (1 = most recent in display)
function M:go_to_index(index)
    -- Convert user index (1=newest) to internal history index (1=oldest)
    local internal_index = #self.buffer_history - index + 1

    if internal_index < 1 or internal_index > #self.buffer_history then
        vim.notify("Invalid history index: " .. index, vim.log.levels.WARN)
        return
    end

    self.is_viewing = true -- Set viewing flag
    local target_entry = self.buffer_history[internal_index]

    if not target_entry then
        if self.debug then vim.notify("[go_to_index] Error: No entry found at internal index " .. internal_index, vim.log.levels.WARN) end
        self.is_viewing = false
        return
    end

     if self.debug then vim.notify("[go_to_index] Attempting to navigate to user index " .. index .. " (internal ".. internal_index .."): bufnr=" .. (target_entry.bufnr or "nil"), vim.log.levels.INFO) end

    local switched = false
    if target_entry.bufnr and vim.api.nvim_buf_is_valid(target_entry.bufnr) then
        vim.api.nvim_set_current_buf(target_entry.bufnr)
        switched = true
    elseif target_entry.filepath and vim.fn.filereadable(target_entry.filepath) == 1 then
        vim.cmd("edit " .. vim.fn.fnameescape(target_entry.filepath))
        target_entry.bufnr = vim.api.nvim_get_current_buf()
        switched = true
    else
        vim.notify("Target buffer/file no longer exists: " .. (target_entry.filepath or ("bufnr " .. (target_entry.bufnr or "?"))), vim.log.levels.WARN)
        self.is_viewing = false
    end

    if switched then
        self.current = internal_index -- Update current pointer
        if self.debug then vim.notify("[go_to_index] Successfully switched buffer. Current set to: " .. self.current, vim.log.levels.INFO) end
    end
end

function M:load_history()
	-- Load object history from a file in the data directory
	local cwd = vim.fn.getcwd()
	-- Sanitize the cwd to create a valid filename
	local sanitized_cwd = cwd:gsub("/", "_"):gsub(":", "_")

	local data_dir = vim.fn.stdpath("data") .. "/buffer_history"
	local file_path = data_dir .. "/" .. sanitized_cwd .. "_buffer_history.json"

	local file = io.open(file_path, "r")
	if file then
		local json = file:read("*a")
		file:close()

		local success, loaded_entries = pcall(vim.json.decode, json)

		if not success or not loaded_entries or type(loaded_entries) ~= "table" then
			vim.notify("Invalid buffer history format in " .. file_path, vim.log.levels.WARN)
			self.buffer_history = {}
			self.current = 0
			return
		end

		-- Process each entry
		self.buffer_history = {}

		for _, entry in ipairs(loaded_entries) do
			-- Handle the case where it might be a legacy format (just buffer numbers)
			if type(entry) == "number" then
				-- Legacy format - just a buffer number
				local bufnr = entry
				if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
					local filepath = vim.api.nvim_buf_get_name(bufnr)
					table.insert(self.buffer_history, {
						bufnr = bufnr,
						filepath = filepath ~= "" and filepath or nil,
					})
				end
			else
				-- New format - table with bufnr and filepath
				local bufnr = entry.bufnr
				local filepath = entry.filepath

				-- Try to find an existing buffer for this file
				if filepath and filepath ~= "" then
					local found = false

					-- Check if file is already open in a buffer
					for _, b in ipairs(vim.api.nvim_list_bufs()) do
						if vim.api.nvim_buf_is_valid(b) and vim.api.nvim_buf_get_name(b) == filepath then
							table.insert(self.buffer_history, {
								bufnr = b,
								filepath = filepath,
							})
							found = true
							break
						end
					end

					-- If not found, still add the entry with filepath
					if not found then
						table.insert(self.buffer_history, {
							bufnr = nil,
							filepath = filepath,
						})
					end
				elseif bufnr and vim.api.nvim_buf_is_valid(bufnr) then
					-- If only buffer number exists and is valid
					table.insert(self.buffer_history, {
						bufnr = bufnr,
						filepath = vim.api.nvim_buf_get_name(bufnr),
					})
				end
			end
		end

		self.current = #self.buffer_history

		if self.debug then
			vim.notify("Loaded buffer history: " .. vim.inspect(self.buffer_history))
			vim.notify("Buffer history loaded with " .. #self.buffer_history .. " entries")
		end

		-- vim.notify("Buffer history loaded from " .. file_path)
		-- If empty, notify
	else
		vim.notify("No buffer history found, starting new session", vim.log.levels.INFO)
		self.buffer_history = {}
		self.current = 0
	end
end

function M:get_previous_buffer()
	if self.current > 1 then
		self.current = self.current - 1
		local entry = self.buffer_history[self.current]

		if self.debug then
			vim.notify("Going to previous buffer: " .. vim.inspect(entry))
		end

		return entry
	else
		if self.debug then
			vim.notify("No previous buffer found.")
		end
		return nil
	end
end

-- Other functions (save_history, display_buffers, _get_updated_buffer_entries,
-- get_buffer_at_index, move_to_back, move_to_front, go_to_index, load_history,
-- get_previous_buffer, go_to_previous_buffer, go_to_next_buffer, setup)
-- remain largely the same, but ensure they use `self.current` consistently
-- and handle potential errors (like invalid buffers during navigation).
-- Make sure navigation functions (`go_to_previous`, `go_to_next`, `go_to_index`)
-- set `self.is_viewing = true` *before* changing the buffer.

-- Example adjustment in navigation functions:
---@param self bufferHistory
function M:go_to_previous_buffer()
    if self.current <= 1 then
         --if self.debug then 
				 vim.notify("[go_to_previous] Already at start.", vim.log.levels.INFO) 
				 --end
         return
    end

    self.is_viewing = true -- Set viewing flag BEFORE potential buffer switch
    local target_index = self.current - 1
    local prev_entry = self.buffer_history[target_index]

    if not prev_entry then -- Should not happen if current > 1, but safety check
        --if self.debug then 
				vim.notify("[go_to_previous] Error: No entry found at index " .. target_index, vim.log.levels.WARN) 
				--end
        self.is_viewing = false -- Reset flag if error occurs
        return
    end

    if self.debug then vim.notify("[go_to_previous] Attempting to navigate to index " .. target_index .. ": bufnr=" .. (prev_entry.bufnr or "nil"), vim.log.levels.INFO) end

    -- Logic to switch buffer (handle invalid/load file)
    local switched = false
    if prev_entry.bufnr and vim.api.nvim_buf_is_valid(prev_entry.bufnr) then
        vim.api.nvim_set_current_buf(prev_entry.bufnr)
        switched = true
    elseif prev_entry.filepath and vim.fn.filereadable(prev_entry.filepath) == 1 then
        vim.cmd("edit " .. vim.fn.fnameescape(prev_entry.filepath))
        -- Update entry with the new buffer number AFTER switching
        prev_entry.bufnr = vim.api.nvim_get_current_buf()
        switched = true
    else
        vim.notify("Previous buffer/file no longer exists: " .. (prev_entry.filepath or ("bufnr " .. (prev_entry.bufnr or "?"))), vim.log.levels.WARN)
        -- Optional: Remove invalid entry here?
        -- table.remove(self.buffer_history, target_index)
        -- Need to decide how to handle current pointer if removed
        self.is_viewing = false -- Reset flag as navigation failed
    end

    -- IMPORTANT: Update current pointer only AFTER successful switch attempt
    -- BufEnter (on_attach) will handle the state based on where we landed.
    -- We set `is_viewing` true; `on_attach` will see that and either just update `current`
    -- if we landed on target_index + 1 (forward nav check in TREE) or reset `is_viewing` otherwise.
    -- The crucial part is that the navigation functions themselves *should not* directly manipulate the history list order. They just change the buffer.
    -- Let's revise: The navigation functions *should* update `self.current` directly because `on_attach` relies on it being correct *before* it runs.

    if switched then
         self.current = target_index -- Update current pointer because we initiated the navigation
         if self.debug then vim.notify("[go_to_previous] Successfully switched buffer. Current set to: " .. self.current, vim.log.levels.INFO) end
    end

    -- No need to recursively call itself on failure here, let user try again.
end

---@param self bufferHistory
function M:go_to_next_buffer()
     if self.current >= #self.buffer_history then
          if self.debug then vim.notify("[go_to_next] Already at end.", vim.log.levels.INFO) end
          return
     end

     self.is_viewing = true -- Set viewing flag
     local target_index = self.current + 1
     local next_entry = self.buffer_history[target_index]

     if not next_entry then
          if self.debug then vim.notify("[go_to_next] Error: No entry found at index " .. target_index, vim.log.levels.WARN) end
          self.is_viewing = false
          return
     end

     if self.debug then vim.notify("[go_to_next] Attempting to navigate to index " .. target_index .. ": bufnr=" .. (next_entry.bufnr or "nil"), vim.log.levels.INFO) end

     local switched = false
     if next_entry.bufnr and vim.api.nvim_buf_is_valid(next_entry.bufnr) then
         vim.api.nvim_set_current_buf(next_entry.bufnr)
         switched = true
     elseif next_entry.filepath and vim.fn.filereadable(next_entry.filepath) == 1 then
         vim.cmd("edit " .. vim.fn.fnameescape(next_entry.filepath))
         next_entry.bufnr = vim.api.nvim_get_current_buf()
         switched = true
     else
         vim.notify("Next buffer/file no longer exists: " .. (next_entry.filepath or ("bufnr " .. (next_entry.bufnr or "?"))), vim.log.levels.WARN)
         self.is_viewing = false
     end

     if switched then
          self.current = target_index -- Update current pointer
          if self.debug then vim.notify("[go_to_next] Successfully switched buffer. Current set to: " .. self.current, vim.log.levels.INFO) end
     end
end

---@class Options
---@field debug boolean Enable debug mode
---@field mode MODES Mode of operation (e.g., "TREE", "FLAT")

---@param opts Options
function M.setup(opts)
	opts = opts or {}
	local debug = opts.debug or false
	local mode = opts.mode or MODES.TREE
	local buffer_history = M.new(mode, debug)

	-- Load history before performing any operations


	if buffer_history == nil then
		vim.notify("[buffer history] Failed to load plugin", vim.log.levels.ERROR)
		return
	end

	buffer_history:load_history()

	if debug then
		vim.notify("current_index: " .. buffer_history.current)
		vim.notify("buffer_history: " .. vim.inspect(buffer_history.buffer_history))
	end
	-- Set up key mappings
	vim.keymap.set('n', '[a', function()
		buffer_history:go_to_previous_buffer()
	end, { noremap = true, silent = true, desc = "Go to previous buffer" })

	vim.keymap.set('n', ']a', function()
		buffer_history:go_to_next_buffer()
	end, { noremap = true, silent = true, desc = "Go to next buffer" })

	vim.keymap.set('n', '<leader>bh', function()
		buffer_history:display_buffers()
	end, { noremap = true, silent = true, desc = "Display buffer history" })

	vim.keymap.set('n', '<leader>bc', function()
		buffer_history:clear()
		vim.notify("Buffer history cleared")
	end, { noremap = true, silent = true, desc = "Clear buffer history" })

	vim.keymap.set('n', '<leader>bf', function()
		buffer_history:move_to_front()
		vim.notify("Moved current buffer to front of history")
	end, { noremap = true, silent = true, desc = "Move current buffer to front" })

	vim.keymap.set('n', '<leader>bb', function()
		buffer_history:move_to_back()
		vim.notify("Moved current buffer to front of history")
	end, { noremap = true, silent = true, desc = "Move current buffer to front" })

	vim.keymap.set('n', "<F1>", function ()
		buffer_history:go_to_index(1);
	end, { noremap = true, silent = true, desc = "Go to 1st buffer" })

	vim.keymap.set('n', "<F2>", function ()
		buffer_history:go_to_index(2);
	end, { noremap = true, silent = true, desc = "Go to 2nd buffer" })

	vim.keymap.set('n', "<F3>", function ()
		buffer_history:go_to_index(3);
	end, { noremap = true, silent = true, desc = "Go to 3rd buffer" })

	vim.keymap.set('n', "<F4>", function ()
		buffer_history:go_to_index(4);
	end, { noremap = true, silent = true, desc = "Go to 4th buffer" })

	vim.keymap.set('n', "<F5>", function ()
		buffer_history:go_to_index(5);
	end, { noremap = true, silent = true, desc = "Go to 5th buffer" })

	vim.keymap.set('n', "<F6>", function ()
		buffer_history:go_to_index(6);
	end, { noremap = true, silent = true, desc = "Go to 6th buffer" })

	vim.keymap.set('n', "<F7>", function ()
		buffer_history:go_to_index(7);
	end, { noremap = true, silent = true, desc = "Go to 7th buffer" })

	vim.keymap.set('n', "<F8>", function ()
		buffer_history:go_to_index(8);
	end, { noremap = true, silent = true, desc = "Go to 8th buffer" })

	vim.keymap.set('n', "<F9>", function ()
		buffer_history:go_to_index(9);
	end, { noremap = true, silent = true, desc = "Go to 9th buffer" })


	---  EVENT LISTENERS 

	-- Attach the buffer history to the current buffer automatically on every buffer switch
	vim.api.nvim_create_autocmd("BufEnter", {
		group = vim.api.nvim_create_augroup("BufferHistory", { clear = true }),
		callback = function()
			buffer_history:on_attach()
		end
	})

	-- Save buffer history when exiting Neovim
	vim.api.nvim_create_autocmd({"VimLeavePre"}, {
		group = vim.api.nvim_create_augroup("BufferHistorySave", { clear = true }),
		callback = function()
			buffer_history:save_history()
		end
	})

	-- Save buffer history when changing directories
	vim.api.nvim_create_autocmd({"DirChanged"}, {
		group = vim.api.nvim_create_augroup("BufferHistorySaveOnDirChange", { clear = true }),
		callback = function()
			buffer_history:save_history()
		end
	})

	-- Save buffer history periodically (every 5 minutes of idle time)
	vim.api.nvim_create_autocmd({"CursorHold", "CursorHoldI"}, {
		group = vim.api.nvim_create_augroup("BufferHistorySavePeriodic", { clear = true }),
		callback = function()
			-- Get the current time
			local current_time = os.time()

			-- If last_save_time doesn't exist or it's been more than 5 minutes
			if not buffer_history.last_save_time or
				(current_time - buffer_history.last_save_time) > 300 then
				buffer_history:save_history()
				buffer_history.last_save_time = current_time
			end
		end
	})

	return buffer_history
end

return M
