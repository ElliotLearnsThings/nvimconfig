---@class BufferHistoryMover
local Mover = {}

---@param self BufferHistory
---@param index integer
---@return boolean success |TRUE| if success
---Goes to the index last entry e.g. go to 1 -> most recent buffer
function Mover:go_to_index(index)

	if index > #self.history then
		vim.print"Does not exist!"
		return false
	end

	assert(index > 0)

	-- Update current_index
	local new_index = #self.history - index + 1

	if new_index < 1 then
		vim.print("Cannot move to buffer at " .. new_index .. "!")
		return false
	end

	assert((self.current_index > 0) and (self.current_index <= #self.history))
	assert((new_index > 0) and (new_index <= #self.history))

	local last_entry = self.history[new_index]
	local is_valid = last_entry.validator.validate(last_entry, self)

	if self.debug then vim.notify(vim.inspect(last_entry)) end

	if not is_valid and last_entry.filepath then
		vim.print"invalid file"
		self.utils.remove(self, last_entry.filepath)
		return false
	end

	if not is_valid and last_entry.bufnr then
		vim.print"bad"
		self.utils.remove(self, nil, last_entry.bufnr)
		return false
	end

	assert(is_valid)

	self.is_viewing = true

	self.current_index = new_index

	if last_entry.bufnr then
		if self.debug then vim.notify"going to buffer number" end
		vim.cmd("buffer " .. last_entry.bufnr)
	elseif last_entry.filepath then
		if self.debug then vim.notify"going to filepath" end
		vim.cmd("edit " .. last_entry.filepath)
	end
	return true
end

---@param self BufferHistory
---@param amount integer
---@return boolean success |TRUE| if success
function Mover:go_back(amount)

	if self.current_index == 1 then
		vim.print("Already at the back of history!")
		return false
	end

	assert(amount > 0)

	-- Update current_index
	local new_index = self.current_index - amount
	if new_index < 1 then
		vim.print("Cannot move " .. amount .. " steps back!")
		return false
	end

	assert((self.current_index > 0) and (self.current_index <= #self.history))
	assert((new_index > 0) and (new_index <= #self.history))
	assert(new_index < self.current_index)

	if self.is_outside then
		self.is_outside = false
		new_index = new_index + 1
	end

	local last_entry = self.history[new_index]
	local is_valid = last_entry.validator.validate(last_entry, self)

	if self.debug then vim.notify(vim.inspect(last_entry)) end

	if not is_valid and last_entry.filepath then
		vim.print"invalid file"
		self.utils.remove(self, last_entry.filepath)
		return false
	end

	if not is_valid and last_entry.bufnr then
		vim.print"bad"
		self.utils.remove(self, nil, last_entry.bufnr)
		return false
	end

	assert(is_valid)

	self.is_viewing = true

	self.current_index = new_index

	if last_entry.bufnr then
		if self.debug then vim.notify"going to buffer number" end
		vim.cmd("buffer " .. last_entry.bufnr)
	elseif last_entry.filepath then
		if self.debug then vim.notify"going to filepath" end
		vim.cmd("edit " .. last_entry.filepath)
	end
	return true
end

---@param self BufferHistory
---@param amount integer
---@return boolean success |TRUE| if success
function Mover:go_forward(amount)

	if self.current_index == #self.history then
		vim.print("Already at the front of history!")
		return false
	end

	if self.current_index > #self.history then return false end
	-- Update current_index
	local new_index = self.current_index + amount
	if new_index > #self.history then return false end

	assert((self.current_index > 0) and (self.current_index <= #self.history))
	assert((new_index > 0) and (new_index <= #self.history))
	assert(new_index > self.current_index)

	local last_entry = self.history[new_index]

	if self.debug then vim.notify(vim.inspect(last_entry)) end

	local is_valid = last_entry.validator.validate(last_entry, self)

	if not is_valid and last_entry.filepath then
		self.utils.remove(self, last_entry.filepath)
		return false
	end

	if not is_valid and last_entry.bufnr then
		self.utils.remove(self, nil, last_entry.bufnr)
		return false
	end

	assert(is_valid)

	-- Only set to true after all valid checks
	self.is_viewing = true
	self.current_index = new_index

	if last_entry.bufnr then
		vim.cmd("buffer " .. last_entry.bufnr)
	elseif last_entry.filepath then
		vim.cmd("edit " .. last_entry.filepath)
	end
	return true
end

return Mover
