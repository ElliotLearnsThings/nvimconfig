--- THINGS LEFT TO ADD
--- Buffer clear (should be easy) DONE Buffer switch to index (should be easy) DONE
--- Display buffers (more difficult but doable)
--- Prune mode buffers (should be ok) - did it ealier, don't know if we really need
--- Prune mode toggle (do we really need?)
--- Is_pinned toggle
--- PAUSE ADDITION for focused owrk
--- Harpoon keys integration (do we really need?)
--- Customisable keys
--- Customisable allowed files for each type

local validators = require("config.buf_switch_2.validation")
local mover = require("config.buf_switch_2.buffer_entries_move")
local buffer_history_util = require("config.buf_switch_2.buffer_history_utils")
local on_attach_handler = require("config.buf_switch_2.on_attach")
local ui = require("config.buf_switch_2.ui")

---@class BufferHistory
---@field debug boolean
---@field history BufferEntry[] oldest first
---@field current_index integer index of the entry being viewed
---@field is_viewing boolean the next BufEnter comes from our own move
---@field paused boolean new buffers are not recorded
---@field is_outside boolean the current buffer is not in the history (tracked while paused)
---@field on_attach BufferHistoryOnAttachHandler
---@field utils BufferHistoryUtils
---@field mover BufferHistoryMover
local M = {}

-- <A-a> .. <A-l> go to entries 1-9 of the bar, <leader>j1 .. <leader>j9 remove them
local quick_switch_keys = { "a", "s", "d", "f", "g", "h", "j", "k", "l" }

---@param debug boolean
---@return BufferHistory buffer_history
function M.new(debug)
	return setmetatable({
		debug = debug,
		history = {},
		current_index = 0,
		is_viewing = true, --- Default to true because we skip on load
		on_attach = on_attach_handler,
		utils = buffer_history_util,
		mover = mover,
		paused = false,
		is_outside = false,
	}, {__index = M})
end

---@class BufferHistoryOptions
---@field debug boolean
---@field startPaused boolean

---@param opts BufferHistoryOptions
---@return BufferHistory
function M.setup(opts)
	local buffer_history = M.new(opts.debug)

	if buffer_history.debug then vim.print(vim.inspect(buffer_history)) end
	if opts.startPaused then
		buffer_history.paused = true
		if buffer_history.debug then vim.notify("Buffer history started in paused mode") end
	end

	-- keep it robust with lazy.nvim + colorscheme changes
	local function refresh_highlights()
		ui.set_highlights()
		ui.update(buffer_history)
	end
	vim.api.nvim_create_autocmd("User", { pattern = "VeryLazy", callback = refresh_highlights })
	vim.api.nvim_create_autocmd("ColorScheme", { callback = refresh_highlights })
	ui.set_highlights()

	-- Every action redraws the bar: a move that fails fires no BufEnter to do it
	local function map(lhs, desc, action)
		vim.keymap.set("n", lhs, function()
			action()
			ui.update(buffer_history)
		end, {desc = desc})
	end

	-- Switching buffers inside neogit, diffview or avante windows would replace their own
	local function map_move(lhs, desc, action)
		map(lhs, desc, function()
			if validators.is_ignored_buffer(vim.api.nvim_get_current_buf()) or validators.is_in_diffview_tab() then
				vim.print("Buffer history: not switching buffers in this window")
				return
			end
			action()
		end)
	end

	------ SCROLL BETWEEN --------

	map_move("<>", "move back a buffer in history", function()
		buffer_history.mover.go_back(buffer_history, math.max(vim.v.count, 1))
	end)

	map_move("><", "move forward a buffer in history", function()
		buffer_history.mover.go_forward(buffer_history, math.max(vim.v.count, 1))
	end)

	------ QUICK SWITCH --------

	for number, key in ipairs(quick_switch_keys) do
		map_move("<A-" .. key .. ">", "go to buffer " .. number .. " in history", function()
			buffer_history.mover.go_to_number(buffer_history, number)
		end)

		map("<leader>j" .. number, "remove buffer " .. number .. " from history", function()
			buffer_history.utils.delete_at_target(buffer_history, number)
		end)
	end

	map_move("<<", "Removes the current buffer and moves to the older one", function()
		buffer_history.utils.remove_current(buffer_history, false)
	end)

	map_move(">>", "Removes the current buffer and moves to the newer one", function()
		buffer_history.utils.remove_current(buffer_history, true)
	end)

	------ MANAGE HISTORY --------

	map("<leader>bb", "Debug buffer history", function()
		vim.notify(vim.inspect(buffer_history.history))
	end)

	map("<leader>jk", "Clear buffer history", function()
		buffer_history.utils.clear(buffer_history)
	end)

	map("<leader>jl", "Toggle pausing the buffer history", function()
		buffer_history.utils.toggle_pause(buffer_history)
	end)

	map("<leader>jj", "Adds the current buffer while paused", function()
		if buffer_history.utils.get_matching_entry_idx(buffer_history, nil, vim.api.nvim_get_current_buf()) then
			vim.notify("Buffer already in history")
			return
		end

		if not (buffer_history.paused or buffer_history.is_viewing) then
			vim.notify("Cannot access in unpaused mode or viewing mode")
			return
		end

		if buffer_history.on_attach.on_attach(buffer_history, true) then -- bypasses the pause
			vim.notify("Added buffer to the end of list!")
		else
			vim.notify("This buffer can't be added to the history")
		end
	end)

	vim.api.nvim_create_autocmd("BufEnter", {
		group = vim.api.nvim_create_augroup("BufferHistory", { clear = true }),
		callback = function(args)
			-- Leave the history, and the winbars neogit/avante draw, untouched
			if validators.is_ignored_buffer(args.buf) or validators.is_in_diffview_tab() then
				return
			end
			buffer_history.on_attach.on_attach(buffer_history)
			ui.update(buffer_history)
		end
	})

	return buffer_history
end

M.history = M.setup({
	debug = false,
	startPaused = false
})

return M
