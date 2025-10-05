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
---@field paused boolean
---@field is_outside boolean
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


	-- e.g. in your plugin/init
	-- call this after colorscheme loads (see autocommands below)
	local function set_winbar_hls()
		-- follow the scheme
		local base = vim.api.nvim_get_hl(0, { name = "TabLineSel", link = false })
		vim.api.nvim_set_hl(0, "WinbarSel", vim.tbl_extend("force", base, { bold = true }))
		vim.api.nvim_set_hl(0, "WinbarDim", { link = "TabLine" })

		-- resolve real colors (no links)
		local sel  = vim.api.nvim_get_hl(0, { name = "WinbarSel", link = false })
		local dim  = vim.api.nvim_get_hl(0, { name = "WinbarDim", link = false })
		local fill = vim.api.nvim_get_hl(0, { name = "TabLineFill", link = false })
		local norm = vim.api.nvim_get_hl(0, { name = "Normal", link = false })

		local sel_bg = sel.bg or fill.bg or norm.bg
		local dim_bg = dim.bg or fill.bg or norm.bg

		-- edge glyphs use the pill bg as their fg
		vim.api.nvim_set_hl(0, "WinbarPillEdgeSel", { fg = dim_bg, bg = "NONE" })
	end

	-- keep it robust with lazy.nvim + colorscheme changes
	vim.api.nvim_create_autocmd("User", { pattern = "VeryLazy", callback = set_winbar_hls })
	vim.api.nvim_create_autocmd("ColorScheme", { callback = set_winbar_hls })
	set_winbar_hls() -- initial call

	------ SCROLL BETWEEN --------

	vim.keymap.set("n", "]a", function ()
		local count = vim.v.count > 0 and vim.v.count or 1
		buffer_history.mover.go_back(buffer_history, count)
	end, {desc = "move back a buffer in history"})

	vim.keymap.set("n", "[a", function ()
		local count = vim.v.count > 0 and vim.v.count or 1
		buffer_history.mover.go_forward(buffer_history, count)
	end, {desc = "move forward a buffer in history"})

	------ QUICK SWITCH --------

	vim.keymap.set("n", "<A-a>", function ()
		buffer_history.mover.go_to_index(buffer_history, 1)
	end, {desc = "move forward a buffer in history"})

	vim.keymap.set("n", "<A-s>", function ()
		buffer_history.mover.go_to_index(buffer_history, 2)
	end, {desc = "move forward a buffer in history"})

	vim.keymap.set("n", "<A-d>", function ()
		buffer_history.mover.go_to_index(buffer_history, 3)
	end, {desc = "move forward a buffer in history"})

	vim.keymap.set("n", "<A-f>", function ()
		buffer_history.mover.go_to_index(buffer_history, 4)
	end, {desc = "move forward a buffer in history"})

	vim.keymap.set("n", "<A-g>", function ()
		buffer_history.mover.go_to_index(buffer_history, 5)
	end, {desc = "move forward a buffer in history"})

	vim.keymap.set("n", "<A-h>", function ()
		buffer_history.mover.go_to_index(buffer_history, 6)
	end, {desc = "move forward a buffer in history"})

	vim.keymap.set("n", "<A-j>", function ()
		buffer_history.mover.go_to_index(buffer_history, 7)
	end, {desc = "move forward a buffer in history"})

	vim.keymap.set("n", "<A-k>", function ()
		buffer_history.mover.go_to_index(buffer_history, 8)
	end, {desc = "move forward a buffer in history"})

	vim.keymap.set("n", "<A-l>", function ()
		buffer_history.mover.go_to_index(buffer_history, 8)
	end, {desc = "move forward a buffer in history"})


	------ CLEAR BUFFER --------

	vim.keymap.set("n", "<leader>bb", function ()
		vim.notify(vim.inspect(buffer_history.history))
		buffer_history.utils.update_ui(buffer_history)
	end, {desc = "Debug buffer history"})

	vim.keymap.set("n", "<leader>jk", function ()
		buffer_history.utils.clear(buffer_history)
		buffer_history.utils.update_ui(buffer_history)
	end, {desc = "Clear buffer history"})

	vim.keymap.set("n", "<leader>jl", function()
		buffer_history.utils.toggle_pause(buffer_history) -- Toggles the pause
		buffer_history.utils.update_ui(buffer_history)
	end, {desc = "Remove the buffer from the history"}
	)

	vim.keymap.set("n", "<leader>jj", function()
		if buffer_history.utils.get_matching_entry_idx(buffer_history, nil, vim.api.nvim_get_current_buf(), nil, false) then
			vim.notify("Buffer already in history")
			return
		end

		if buffer_history.paused or buffer_history.is_viewing then
			buffer_history.on_attach.on_attach(buffer_history, true) -- Bypassed blocks - adds new buffer
			buffer_history.mover.go_to_index(buffer_history, 1)
			buffer_history.utils.update_ui(buffer_history)
			buffer_history.mover.go_back(buffer_history, 1)
			vim.notify"Added buffer to the end of list!"
		else
			vim.notify"Cannot access in unpaused mode or viewing mode"
		end
	end, {desc = "Adds a buffer while in blocked mode"}
	)

	vim.keymap.set("n", "[r", function()

		if #buffer_history.history <= 1 then
			return
		end

		local init_index = buffer_history.current_index
		-- e.g. current_index = 4, pos = 2
		table.remove(buffer_history.history, init_index) -- Bypassed blocks - adds new buffer
		buffer_history.utils.fix_levels(buffer_history)

		buffer_history.current_index = init_index - 1

		buffer_history.mover.go_to_index(buffer_history, #buffer_history.history - buffer_history.current_index + 1)
		buffer_history.utils.update_ui(buffer_history)
		--vim.notify("Removed the buffer!" .. buffer_history.current_index)
	end, {desc = "Removes a buffer and move up one"}
	)

	vim.keymap.set("n", "]r", function()
		-- **
		if #buffer_history.history <= 1 then
			return
		end

		local init_index = buffer_history.current_index
		-- e.g. current_index = 4, pos = 2
		table.remove(buffer_history.history, init_index) -- Bypassed blocks - adds new buffer
		buffer_history.utils.fix_levels(buffer_history)

		if init_index > 1 and #buffer_history.history > 0 then
			-- current_index = 3, pos = 3
			buffer_history.current_index = init_index - 1
		else
			buffer_history.current_index = init_index
		end

		buffer_history.mover.go_to_index(buffer_history, #buffer_history.history - buffer_history.current_index + 1)
		buffer_history.utils.update_ui(buffer_history)
		--vim.notify("Removed the buffer!" .. buffer_history.current_index)
	end, {desc = "Removes a buffer and move down one"}
	)

	vim.keymap.set("n", "<leader>j1", function()
		buffer_history.utils.delete_at_target(buffer_history, 1)
	end, {desc = "Removes the buffer at index 1"}
	)

	vim.keymap.set("n", "<leader>j2", function()
		buffer_history.utils.delete_at_target(buffer_history, 2)
	end, {desc = "Removes the buffer at index 2"}
	)

	vim.keymap.set("n", "<leader>j3", function()
		buffer_history.utils.delete_at_target(buffer_history, 3)
	end, {desc = "Removes the buffer at index 3"}
	)

	vim.keymap.set("n", "<leader>j4", function()
		buffer_history.utils.delete_at_target(buffer_history, 4)
	end, {desc = "Removes the buffer at index 4"}
	)

	vim.keymap.set("n", "<leader>j5", function()
		buffer_history.utils.delete_at_target(buffer_history, 5)
	end, {desc = "Removes the buffer at index 5"}
	)

	vim.keymap.set("n", "<leader>j6", function()
		buffer_history.utils.delete_at_target(buffer_history, 6)
	end, {desc = "Removes the buffer at index 6"}
	)

	vim.keymap.set("n", "<leader>j7", function()
		buffer_history.utils.delete_at_target(buffer_history, 7)
	end, {desc = "Removes the buffer at index 7"}
	)

	vim.keymap.set("n", "<leader>j8", function()
		buffer_history.utils.delete_at_target(buffer_history, 8)
	end, {desc = "Removes the buffer at index 8"}
	)

	vim.keymap.set("n", "<leader>j9", function()
		buffer_history.utils.delete_at_target(buffer_history, 8)
	end, {desc = "Removes the buffer at index 8"}
	)

	vim.api.nvim_create_autocmd("BufEnter", {
		group = vim.api.nvim_create_augroup("BufferHistory", { clear = true }),
		callback = function()
			buffer_history.on_attach.on_attach(buffer_history)
			buffer_history.utils.update_ui(buffer_history)
			--vim.notify("cur_index = " .. buffer_history.current_index)
		end
	})

	return buffer_history
end

return M
