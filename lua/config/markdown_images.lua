-- Images in markdown drawn by snacks.nvim (embedded images and typeset math blocks):
--   * each one drawn at the size snacks laid it out, not at the size of an old copy
--   * embedded images and display math centered in the window, inline math left alone
-- These patch snacks internals (snacks.image.image, .placement), so recheck them after
-- updating snacks. Set up before config/markdown_math.lua, whose patches wrap these.
--
-- The terminal finds an image's placement from its placeholder cells: the image id is
-- in the foreground color and the placement id in the underline color. Neovim only
-- sends an underline color for text with an underline, so the placement id never
-- arrives and the terminal draws whichever placement of that image it finds first.
-- One left over at another size drew a figure in the corner of a mostly black area,
-- or a formula wider than its cells and cut off. So a placement leaves the terminal
-- once snacks closes it or its buffer is no longer in any window.

local M = {}

---@param p snacks.image.Placement
local function should_center(p)
	return p.opts.inline and not p.img.src:find("%.mathinline%.tex$")
end

--- The narrowest text area among the windows showing a placement.
---@param wins number[]
local function text_width(wins)
	local width = math.huge
	for _, win in ipairs(wins) do
		local info = vim.fn.getwininfo(win)[1]
		width = math.min(width, info.width - info.textoff)
	end
	return width
end

---@param chunk [string, any]
local function is_image(chunk)
	return type(chunk[2]) == "string" and chunk[2]:find("^SnacksImage%d") ~= nil
end

function M.setup()
	local terminal = Snacks.image.terminal
	local image = require("snacks.image.image")
	local placement = require("snacks.image.placement")

	-- Snacks deleted placement `p = <loop index>` rather than the placement's id, so a
	-- closed placement stayed in the terminal for as long as its image had another one.
	function image:del(pid)
		for _, p in ipairs(pid and { pid } or vim.tbl_keys(self.placements)) do
			if self.placements[p] then
				terminal.request({ a = "d", d = "i", i = self.id, p = p })
				self.placements[p] = nil
			end
		end
		if not next(self.placements) then
			terminal.request({ a = "d", d = "i", i = self.id })
		end
	end

	-- Placements that have been drawn, to find a buffer's when it leaves its window.
	local drawn = setmetatable({}, { __mode = "k" }) ---@type table<snacks.image.Placement, true>
	local update = placement.update
	function placement:update()
		drawn[self] = true
		return update(self)
	end

	-- A buffer that left every window kept its placements, sized for windows that may
	-- have changed since, as when the same note is open from two paths. Take them out
	-- of the terminal. Without a state, snacks places them anew once the buffer is shown.
	vim.api.nvim_create_autocmd("BufWinLeave", {
		group = vim.api.nvim_create_augroup("markdown_images", { clear = true }),
		callback = function(ev)
			vim.schedule(function()
				if #vim.fn.win_findbuf(ev.buf) > 0 then
					return
				end
				for p in pairs(drawn) do
					if p.buf == ev.buf and p._state and not p.closed then
						terminal.request({ a = "d", d = "i", i = p.img.id, p = p.id })
						p._state = nil
					end
				end
			end)
		end,
	})

	-- The text width is part of the state, so a resized window centers again.
	local state = placement.state
	function placement:state()
		local ret = state(self)
		if should_center(self) and #ret.wins > 0 then
			ret.text_width = text_width(ret.wins)
		end
		return ret
	end

	-- Center the rows below the source and the rows drawn over it, which snacks
	-- starts at the source column.
	local render = placement._render
	function placement:_render(extmarks)
		local s = self._state
		if s and s.text_width and not self.hidden then
			local pad = math.max(0, math.floor((s.text_width - s.loc.width) / 2))
			local indent = { string.rep(" ", pad) }
			for _, e in ipairs(extmarks) do
				if e.virt_text_win_col then
					e.virt_text_win_col = pad
				end
				if e.virt_lines then
					e.virt_lines = vim.tbl_map(function(line)
						local img = vim.iter(line):find(is_image)
						return img and { indent, img } or line
					end, e.virt_lines)
				end
			end
		end
		return render(self, extmarks)
	end
end

return M
