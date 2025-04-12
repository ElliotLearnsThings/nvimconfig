--- THINGS LEFT TO ADD
--- Buffer clear (should be easy) DONE
--- Buffer switch to index (should be easy) 
--- Display buffers (more difficult but doable)
--- Prune mode buffers (should be ok) - did it ealier
--- Prune mode toggle
--- Is_pinned toggle
--- Harpoon keys integration
--- Customisable keys 
--- Customisable allowed files for each type

local validators = require("config.buf_switch_2.validation")

---@class BufferHistoryMover
local mover = require("config.buf_switch_2.buffer_entries_move")

---@class BufferHistoryUtil
local buffer_history_util = require("config.buf_switch_2.buffer_history_utils")

---@class BufferHistoryOnAttachHandler
local on_attach_handler = require("config.buf_switch_2.on_attach")

---@class BufferHistoryValidator
local buffer_history_validator = validators.BufferHistoryValidator

---@class BufferHistory
---@field debug boolean
---@field history BufferEntry[]
---@field current_index integer
---@field is_viewing boolean
---@field validator BufferHistoryValidator
---@field on_attach BufferHistoryOnAttachHandler
---@field utils BufferHistoryUtils
---@field mover BufferHistoryMover
local M = {}

---@param debug boolean
---@return BufferHistory buffer_history
function M.new(debug)
	return setmetatable({
		debug=debug,
		history = {},
		current_index=0,
		is_viewing = true, --- Default to true because we skip on load
		validator = buffer_history_validator,
		on_attach = on_attach_handler,
		utils = buffer_history_util,
		mover = mover,
	}, {__index = M})
end

---@class BufferHistoryOptions
---@field debug boolean

---@param opts BufferHistoryOptions
---@return BufferHistory
function M.setup(opts)
	local buffer_history = M.new(opts.debug)

	if buffer_history.debug then vim.print(vim.inspect(buffer_history)) end

	------ SCROLL BETWEEN --------

	vim.keymap.set("n", "[a", function ()
		local count = vim.v.count > 0 and vim.v.count or 1
		buffer_history.mover.go_back(buffer_history, count)
	end, {desc = "move back a buffer in history"})

	vim.keymap.set("n", "]a", function ()
		local count = vim.v.count > 0 and vim.v.count or 1
		buffer_history.mover.go_forward(buffer_history, count)
	end, {desc = "move forward a buffer in history"})

	------ QUICK SWITCH --------

	vim.keymap.set("n", "<F1>", function ()
		buffer_history.mover.go_to_index(buffer_history, 1)
	end, {desc = "move forward a buffer in history"})

	vim.keymap.set("n", "<F2>", function ()
		buffer_history.mover.go_to_index(buffer_history, 2)
	end, {desc = "move forward a buffer in history"})

	vim.keymap.set("n", "<F3>", function ()
		buffer_history.mover.go_to_index(buffer_history, 3)
	end, {desc = "move forward a buffer in history"})

	vim.keymap.set("n", "<F4>", function ()
		buffer_history.mover.go_to_index(buffer_history, 4)
	end, {desc = "move forward a buffer in history"})

	vim.keymap.set("n", "<F5>", function ()
		buffer_history.mover.go_to_index(buffer_history, 5)
	end, {desc = "move forward a buffer in history"})

	vim.keymap.set("n", "<F6>", function ()
		buffer_history.mover.go_to_index(buffer_history, 6)
	end, {desc = "move forward a buffer in history"})

	vim.keymap.set("n", "<F7>", function ()
		buffer_history.mover.go_to_index(buffer_history, 7)
	end, {desc = "move forward a buffer in history"})


	------ CLEAR BUFFER --------

	vim.keymap.set("n", "<leader>bp", function ()
		vim.notify(vim.inspect(buffer_history.history))
	end, {desc = "Debug buffer history"})

	vim.keymap.set("n", "<leader>bc", function ()
		buffer_history.utils.clear(buffer_history)
	end, {desc = "Clear buffer history"})

	vim.keymap.set("n", "<leader>br", function()
		vim.notify"not implemented yet"
	end, {desc = "Remove the buffer from the history"}
	)

	vim.api.nvim_create_autocmd("BufEnter", {
		group = vim.api.nvim_create_augroup("BufferHistory", { clear = true }),
		callback = function()
			buffer_history.on_attach.on_attach(buffer_history)
		end
	})

	return buffer_history
end

return M
