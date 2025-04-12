local validators = require("config.buf_switch_2.validation")

---@class BufferEntryValidator
local buffer_entry_validator = validators.BufferEntryValidator

---@class BufferEntry
---@field filepath string
---@field level integer
---@field is_pinned boolean
---@field bufnr? integer
---@field validator BufferEntryValidator
local M = {}

---@param bufnr integer
---@return string? is_valid
function Get_filepath_from_bufnr(bufnr)
	local filepath = vim.api.nvim_buf_get_name(bufnr)
	return filepath ~= "" and filepath or nil
end

---@class NewEntryOpts
---@field filepath? string
---@field is_pinned? boolean
---@field bufnr? integer

---@param history BufferHistory
---@param opts NewEntryOpts
---@return BufferEntry? bufentry
---Warning - does not include validation logic, use self.validator.validate(self)
function M.new(history, opts)
	--- Validate inputs - note bufnr can be nil
	local bufnr = opts.bufnr
	local filepath = opts.filepath
	local is_pinned = opts.is_pinned


	if not opts.filepath then
		if history.debug then vim.print(vim.inspect("No filepath given in entry constructor, finding local...")) end
		bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
		filepath = Get_filepath_from_bufnr(bufnr)
	end

	if not is_pinned then is_pinned = false end

	if filepath == nil then
		return nil
	end

	assert(filepath ~= nil)
	assert(is_pinned ~= nil)

	--- Find level
	local already_found = false
	local new_level
	local max_level = 0

	for _, entry in ipairs(history.history) do
		if entry.filepath == filepath then
			already_found = true
			new_level = entry.level
		end

		if entry.level > max_level then
			max_level = entry.level
		end
	end

	if not already_found then
		new_level = max_level + 1
	end

	if already_found then assert(new_level <= max_level) end
	assert(filepath ~= nil)
	assert(is_pinned ~= nil)
	assert(new_level ~= nil)

	local new_entry = setmetatable({
		filepath = filepath,
		is_pinned = is_pinned or false,
		bufnr = bufnr or nil,
		level = new_level,
		validator = buffer_entry_validator,
	}, {__index = M})

	--- Include validation in constructor
	return new_entry
end

return M
