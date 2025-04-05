---@class bufferHistory
---@field buffer_history table[] List of entries with {bufnr=number, filepath=string}
---@field current integer current buffer index
---@field debug boolean debug mode
---@field is_load boolean flag for initial load
---@field is_viewing boolean is viewing previous
---@field last_save_time number timestamp of last save
local M = {}

--- Create a new buffer history object
--- @param debug boolean whether to enable debug mode
function M.new(debug)
	local bufnr = vim.api.nvim_get_current_buf()

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
	}

	return setmetatable(this, {
		__index = M,
		__tostring = function(self)
			return "BufferHistory: " .. vim.inspect(self.buffer_history)
		end
	})
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

	-- Update the current pointer if needed
	if self.current > #self.buffer_history then
		self.current = #self.buffer_history
	end
end

function M:clear()
	self.buffer_history = {}
	self.current = 0
end

function M:on_attach()
	self:validate()
	if self.is_load then
		vim.notify("Skipping on load")
		self.is_load = false
		return
	end

	local bufnr = vim.api.nvim_get_current_buf()
	local filepath = vim.api.nvim_buf_get_name(bufnr)

	-- Multiple checks to identify special buffers
	local buf_type = vim.bo[bufnr].buftype
	local ft = vim.bo[bufnr].filetype

	-- Skip special buffer types
	if buf_type ~= "" then
		if self.debug then
			vim.notify("Skipping non-normal buffer type: " .. buf_type, vim.log.levels.DEBUG)
		end
		return
	end

	-- Skip oil buffers specifically
	if ft == "oil" then
		if self.debug then
			vim.notify("Skipping oil buffer", vim.log.levels.DEBUG)
		end
		return
	end

	-- Skip buffers with oil:// protocol
	if filepath:match("^oil://") then
		if self.debug then
			vim.notify("Skipping oil:// buffer", vim.log.levels.DEBUG)
		end
		return
	end

	if ft:match("harpoon") or ft:match("TelescopePrompt") then
		if self.debug then
			vim.notify("Skipping harpoon/telescope menu", vim.log.levels.DEBUG)
		end
		return
	end

	if self.debug then
		vim.notify("buffer_history: " .. vim.inspect(self.buffer_history), vim.log.levels.INFO)
	end

	if bufnr == -1 then
		vim.notify("Error attaching buffer history", vim.log.levels.ERROR)
		return
	end

	-- Check if the last buffer is the same as the current
	local last_entry = self.buffer_history[self.current]
	if last_entry and last_entry.bufnr == bufnr then
		if self.debug then
			vim.notify("Skipping buffer history update, same buffer: " .. bufnr)
		end
		return
	end

	-- Check if the buffer is already in the history
	local existing_idx = nil
	for idx, entry in ipairs(self.buffer_history) do
		if entry.bufnr == bufnr or (filepath ~= "" and entry.filepath == filepath) then
			existing_idx = idx
			break
		end
	end

	if existing_idx then
		-- Buffer exists in history
		if not self.is_viewing then
			-- Remove it from current position
			table.remove(self.buffer_history, existing_idx)
			-- Add it to the end for recency
			local new_entry = {
				bufnr = bufnr,
				filepath = filepath ~= "" and filepath or nil
			}
			table.insert(self.buffer_history, new_entry)
			self.current = #self.buffer_history
		else
			self.is_viewing = false
		end
	else
		-- If not in history, add it to the end
		local new_entry = {
			bufnr = bufnr,
			filepath = filepath ~= "" and filepath or nil
		}
		table.insert(self.buffer_history, new_entry)
		self.current = #self.buffer_history
	end

	if self.debug then
		vim.notify("Buffer history updated with buffer number: " .. bufnr)
		vim.notify("current_index: " .. self.current)
		vim.notify("buffer_history: " .. vim.inspect(self.buffer_history))
	end
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
					filepath = filepath ~= "" and filepath or nil
				})
			elseif filepath and filepath ~= "" and vim.fn.filereadable(filepath) == 1 then
				-- Keep entry if file exists even if buffer doesn't
				table.insert(valid_entries, {
					bufnr = nil,  -- Buffer no longer exists
					filepath = filepath
				})
			end
		end

		local json = vim.json.encode(valid_entries)
		file:write(json)
		file:close()
		-- vim.notify("Buffer history saved to " .. file_path)
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
	for idx = #self.buffer_history, 1, -1 do
		local entry = self.buffer_history[idx]
		local bufnr = entry.bufnr
		local filepath = entry.filepath
		local display_name

		-- Check if buffer is valid
		local is_valid_buffer = bufnr and vim.api.nvim_buf_is_valid(bufnr)

		if is_valid_buffer then
			-- Use buffer info for display
			local name = vim.api.nvim_buf_get_name(bufnr)
			if name == "" then
				display_name = (#self.buffer_history - idx + 1) .. ": " .. bufnr .. " - [Unnamed buffer]"
			else
				display_name = (#self.buffer_history - idx + 1) .. ": " .. bufnr .. " - " .. vim.fn.fnamemodify(name, ":~:.")
			end
		elseif filepath and filepath ~= "" then
			-- Use filepath for display (buffer doesn't exist yet)
			display_name = (#self.buffer_history - idx + 1) .. ": ⟳ " .. vim.fn.fnamemodify(filepath, ":~:.")

			-- Try to find if file exists
			if vim.fn.filereadable(filepath) ~= 1 then
				display_name = (#self.buffer_history - idx + 1) .. ": ! " .. display_name -- Mark files that don't exist
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

		if self.debug then
			vim.notify("Display entries: " .. vim.inspect(buffer_entries))
		end

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

			-- Delete buffer from history on <c-d>
			map("i", "<c-d>", function()
				local selection = action_state.get_selected_entry()

				if self.debug then
					vim.notify("Deleting entry: " .. vim.inspect(selection))
				end

				-- Remove the entry from history
				table.remove(self.buffer_history, selection.index)

				-- Update current pointer if needed
				if self.current >= selection.index then
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
					vim.notify("Item moved to front of history")
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
	for idx = #self.buffer_history, 1, -1 do
		local entry = self.buffer_history[idx]
		local bufnr = entry.bufnr
		local filepath = entry.filepath

		-- For buffer preview and display
		local is_valid_buffer = bufnr and bufnr ~= -1 and vim.api.nvim_buf_is_valid(bufnr)
		local display_name

		if is_valid_buffer then
			-- Use buffer info for display
			local name = vim.api.nvim_buf_get_name(bufnr)
			if name == "" then
				display_name = (#self.buffer_history - idx + 1) .. ": " .. bufnr .. " - [Unnamed buffer]"
			else
				display_name = (#self.buffer_history - idx + 1) .. ": " .. bufnr .. " - " .. vim.fn.fnamemodify(name, ":~:.")
			end
		elseif filepath and filepath ~= "" then
			-- Use filepath for display (buffer doesn't exist yet)
			display_name = (#self.buffer_history - idx + 1) .. ": ⟳ " .. vim.fn.fnamemodify(filepath, ":~:.")

			-- Try to find if file exists
			if vim.fn.filereadable(filepath) ~= 1 then
				display_name = (#self.buffer_history - idx + 1) .. ": ! " .. display_name
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
	if not target_bufnr and not target_filepath then
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

function M:go_to_index(index)
	self.is_viewing = true
	local entry = self:get_buffer_at_index(index)

	if not entry then
		vim.notify("No buffer found at index " .. index)
		return
	end

	if entry.bufnr and vim.api.nvim_buf_is_valid(entry.bufnr) then
		-- Buffer exists, switch to it
		vim.api.nvim_set_current_buf(entry.bufnr)
	elseif entry.filepath and vim.fn.filereadable(entry.filepath) == 1 then
		-- Buffer doesn't exist but file does, open it
		vim.cmd("edit " .. vim.fn.fnameescape(entry.filepath))

		-- Update buffer number in history
		entry.bufnr = vim.api.nvim_get_current_buf()
	else
		vim.notify("Buffer no longer exists: " ..
		(entry.filepath or "unknown"), vim.log.levels.WARN)
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
						filepath = filepath ~= "" and filepath or nil
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
								filepath = filepath
							})
							found = true
							break
						end
					end

					-- If not found, still add the entry with filepath
					if not found then
						table.insert(self.buffer_history, {
							bufnr = nil,
							filepath = filepath
						})
					end
				elseif bufnr and vim.api.nvim_buf_is_valid(bufnr) then
					-- If only buffer number exists and is valid
					table.insert(self.buffer_history, {
						bufnr = bufnr,
						filepath = vim.api.nvim_buf_get_name(bufnr)
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

function M:go_to_previous_buffer()
	self.is_viewing = true
	local prev_entry = self:get_previous_buffer()

	if not prev_entry then
		vim.notify("No previous buffer found. current_index: " .. self.current)
		return
	end

	if prev_entry.bufnr and vim.api.nvim_buf_is_valid(prev_entry.bufnr) then
		-- Buffer exists, switch to it
		vim.api.nvim_set_current_buf(prev_entry.bufnr)
	elseif prev_entry.filepath and vim.fn.filereadable(prev_entry.filepath) == 1 then
		-- Buffer doesn't exist but file does, open it
		vim.cmd("edit " .. vim.fn.fnameescape(prev_entry.filepath))

		-- Update buffer number in history
		prev_entry.bufnr = vim.api.nvim_get_current_buf()
	else
		vim.notify("Previous buffer no longer exists: " ..
		(prev_entry.filepath or "unknown"), vim.log.levels.WARN)

		-- Skip to next previous buffer
		self:go_to_previous_buffer()
	end
end

function M:go_to_next_buffer()
	self.is_viewing = true
	if self.current < #self.buffer_history then
		self.current = self.current + 1
		local entry = self.buffer_history[self.current]

		if entry.bufnr and vim.api.nvim_buf_is_valid(entry.bufnr) then
			-- Buffer exists, switch to it
			vim.api.nvim_set_current_buf(entry.bufnr)
		elseif entry.filepath and vim.fn.filereadable(entry.filepath) == 1 then
			-- Buffer doesn't exist but file does, open it
			vim.cmd("edit " .. vim.fn.fnameescape(entry.filepath))

			-- Update buffer number in history
			entry.bufnr = vim.api.nvim_get_current_buf()
		else
			vim.notify("Next buffer no longer exists: " ..
			(entry.filepath or "unknown"), vim.log.levels.WARN)

			-- Skip to next buffer
			self:go_to_next_buffer()
		end
	else
		vim.notify("No next buffer found.")
	end
end

function M.setup(opts)
	opts = opts or {}
	local debug = opts.debug or false
	local buffer_history = M.new(debug)

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
