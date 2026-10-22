-- LaTeX math in markdown, typeset by snacks.nvim (tectonic -> image) and made to read
-- like a typeset document:
--   * body text color; inline formulas in text style, all at one size
--   * inline formulas and blocks drawn at the same scale
--   * wide formulas typeset in full instead of cut off at the page edge
--   * inline formulas drawn over their source, so lines with math wrap less early
--   * only the formula under the cursor shows its source, and a block being edited
--     keeps its result below it
--   * in insert mode, images update once typing pauses
-- These patch snacks internals (snacks.image.doc, .placement, .inline), so recheck them
-- after updating snacks. Needs 'concealcursor' to keep the cursor line concealed, see
-- after/ftplugin/markdown.lua.

local M = {}

-- Inline math sits on a strut from 0.9em above the baseline to 0.35em below, tall
-- enough for most sub/superscripts, and one strut is drawn as one row.
local em_pt = 17.28 -- \Large in the 12pt standalone class, set in M.opts
local strut = { height = 0.9, depth = 0.35 }
local row_pt = (strut.height + strut.depth) * em_pt

-- Obsidian's MathJax doesn't number these; unnumbered also keeps the image from
-- stretching to full width for the (1), (2) labels.
local numbered = { equation = true, align = true, gather = true, multline = true, flalign = true, alignat = true }

---@param a number[] (row, col)
---@param b number[] (row, col)
local function before(a, b)
	return a[1] < b[1] or (a[1] == b[1] and a[2] < b[2])
end

--- Where formulas show their source: at the cursor or in the visual selection, or on
--- whole lines where 'concealcursor' makes Neovim reveal them anyway.
local function revealed()
	local mode = vim.fn.mode()
	local flag = ({ V = "v", ["\22"] = "v", R = "i" })[mode:sub(1, 1)] or mode:sub(1, 1)
	local cur = vim.api.nvim_win_get_cursor(0)
	local from, to = { cur[1] - 1, cur[2] }, { cur[1] - 1, cur[2] }
	if flag == "v" then
		local v = vim.fn.getpos("v")
		local other = { v[2] - 1, v[3] - 1 }
		if before(other, from) then
			from = other
		else
			to = other
		end
	end
	if mode == "V" or mode == "\22" or not vim.wo.concealcursor:find(flag, 1, true) then
		return { from = { from[1], 0 }, to = { to[1], math.huge } }
	end
	-- The normal-mode cursor covers a character, so the one after a closing `$` is outside.
	return { from = from, to = to, exclusive = flag ~= "i" }
end

---@param p snacks.image.Placement
local function span(p)
	local id = p.eids and p.eids[1]
	local m = id and vim.api.nvim_buf_get_extmark_by_id(p.buf, Snacks.image.placement.ns, id, { details = true })
	-- The extmark follows edits that the placement's range only picks up on the next update.
	if m and m[1] and m[3].end_row and not m[3].invalid then
		return { m[1], m[2] }, { m[3].end_row, m[3].end_col }
	end
	local r = p.opts.range
	return { r[1] - 1, r[2] }, { r[3] - 1, r[4] }
end

---@param p snacks.image.Placement
local function is_revealed(p, sel)
	local s, e = span(p)
	if before(sel.to, s) then
		return false
	end
	if sel.exclusive then
		return before(sel.from, e)
	end
	return not before(e, sel.from)
end

---@param p snacks.image.Placement
local function is_block(p)
	return p.img.src:find("%.math%.tex$") ~= nil
end

local placeholder = vim.fn.nr2char(0x10EEEE) -- starts each cell of an image

--- Neovim wraps a line as if its concealed text were still there (neovim/neovim#14409),
--- and snacks inserts an inline formula's image beside its concealed source, so the
--- formula took up both widths. Rows with math ended early, and since 'linebreak'
--- doesn't count inserted text, they broke mid-word, leaving a `.` to start the next
--- row. Draw the image over its own source instead, on a run of characters that
--- 'linebreak' can't split, and conceal the rest. Only the cells that don't fit on the
--- run are inserted. The concealed source still takes up its width.
---@param buf number
---@param extmarks snacks.image.Extmark[]
local function over_source(buf, extmarks)
	local e = extmarks[1]
	if #extmarks ~= 1 or e.virt_text_pos ~= "inline" or not e.conceal or e.end_row ~= e.row then
		return extmarks
	end
	local text, hl = e.virt_text[1][1], e.virt_text[1][2]
	local cells = {} ---@type string[]
	local i = 1
	while i <= #text do
		local j = text:find(placeholder, i + 1, true) or #text + 1
		cells[#cells + 1] = text:sub(i, j - 1)
		i = j
	end

	-- The longest run, up to the image width, of one-cell characters not in 'breakat'.
	-- Treesitter conceals the backslash of an escape like `\{`, even inside math.
	local line = vim.api.nvim_buf_get_lines(buf, e.row, e.row + 1, false)[1] or ""
	local breakat = vim.o.breakat
	local from, len, run = e.col, 0, e.col
	for col = e.col, e.end_col - 1 do
		local c = line:sub(col + 1, col + 1)
		local b = c:byte()
		if
			not b
			or b <= 32
			or b >= 127
			or breakat:find(c, 1, true)
			or (c == "\\" and line:sub(col + 2, col + 2):find("^%p"))
		then
			run = col + 1
		elseif col + 1 - run > len then
			from, len = run, col + 1 - run
			if len == #cells then
				break
			end
		end
	end

	local function mark(col, end_col, opts)
		return vim.tbl_extend("force", {
			row = e.row,
			col = col,
			end_row = end_col and e.row,
			end_col = end_col,
			invalidate = end_col and e.invalidate,
		}, opts or {})
	end
	local ret = { mark(e.col, e.end_col) } -- spans the formula, see span()
	if from > e.col then
		ret[#ret + 1] = mark(e.col, from, { conceal = e.conceal })
	end
	if len > 0 then
		ret[#ret + 1] = mark(from, from + len, {
			virt_text_pos = "overlay",
			virt_text = { { table.concat(cells, "", 1, len), hl } },
			virt_text_hide = false,
		})
	end
	local rest = from + len
	if rest < e.end_col or len < #cells then
		ret[#ret + 1] = mark(rest, rest < e.end_col and e.end_col or nil, {
			conceal = rest < e.end_col and e.conceal or nil,
			virt_text_pos = len < #cells and "inline" or nil,
			virt_text = len < #cells and { { table.concat(cells, "", len + 1), hl } } or nil,
			virt_text_hide = e.virt_text_hide,
		})
	end
	return ret
end

--- Puts each changed formula's new, compiled image into the placement at its position
--- and draws it at once, so the old image stays on screen until it is replaced.
---@param inl snacks.image.inline
---@param found snacks.image.match[]
local function swap(inl, found)
	local function kind(src)
		return src:match("%.(math%a*)%.tex$")
	end
	local at = {} ---@type table<string, snacks.image.Placement>
	for _, p in pairs(inl.imgs) do
		local s = span(p)
		at[s[1] .. ":" .. s[2]] = p
	end
	for _, i in ipairs(found) do
		local p = at[(i.range[1] - 1) .. ":" .. i.range[2]]
		if p and p.img.src ~= i.src and kind(i.src) and kind(i.src) == kind(p.img.src) then
			local img = Snacks.image.image.new(i.src)
			if img:ready() then
				local old = p.img
				p.img, p.opts.pos, p.opts.range, p._state = img, i.pos, i.range, nil
				img:place(p)
				Snacks.image.placement.update(p) -- the class method; instances debounce it
				old:del(p.id)
			end
		end
	end
end

-- Merged into the snacks `image` opts.
M.opts = {
	math = { latex = { font_size = "Large" } }, -- see em_pt
	-- Inline math is trimmed only left and right, keeping the strut. Picked by the
	-- `mathinline.tex` ext set in the latex transform.
	convert = {
		magick = {
			mathinline = { "-density", 192, "{src}[{page}]", "-define", "trim:edges=east,west", "-trim", "+repage" },
		},
	},
	doc = {
		-- Images that are new or redrawn under the cursor start out revealed rather than
		-- waiting for the cursor to move.
		---@param p snacks.image.Placement
		on_update_pre = function(p)
			if p.opts.inline and p.opts.conceal and p.buf == vim.api.nvim_get_current_buf() then
				p.hidden = is_revealed(p, revealed())
			end
		end,
	},
}

function M.setup()
	-- Math in the body text color, as in a typeset document. Snacks defaults to
	-- `Special`, which is orange in gruvbox. Re-linked after `:colorscheme` clears it.
	local function math_hl()
		vim.api.nvim_set_hl(0, "SnacksImageMath", { link = "Normal" })
	end
	math_hl()
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = vim.api.nvim_create_augroup("markdown_math_hl", { clear = true }),
		callback = math_hl,
	})

	local transforms = require("snacks.image.doc").transforms
	local latex = transforms.latex
	-- The standalone `varwidth` option caps a line at the default text width, so a
	-- wide formula ran off the page and its image was cut at the right edge. The page
	-- still shrinks to the formula, and magick trims what is left.
	local function typeset(img, ctx)
		latex(img, ctx)
		img.content = img.content:gsub("varwidth,", "varwidth=100cm,", 1)
	end
	transforms.latex = function(img, ctx)
		if not img.content then
			return latex(img, ctx)
		end
		if ctx.pos.node:type() == "inline_formula" then
			-- Snacks typesets `$x$` as display math; use text style like Obsidian.
			local content = img.content:gsub("^%$", ""):gsub("%$$", "")
			img.content = ("\\begin{math}\\rule[-%gem]{0pt}{%gem}%s\\end{math}"):format(
				strut.depth,
				strut.height + strut.depth,
				vim.trim(content)
			)
			typeset(img, ctx)
			img.ext = "mathinline.tex"
			return
		end
		-- snacks checks for `\begin` before trimming the newline after `$$`, so a
		-- $$\n\begin{align}...$$ block got wrapped in \[...\] and lost its alignment.
		local content = vim.trim((img.content:gsub("^%$%$", ""):gsub("%$%$$", "")))
		img.content = content:gsub("\\(%a+){(%a+)}", function(cmd, env)
			if (cmd == "begin" or cmd == "end") and numbered[env] then
				return ("\\%s{%s*}"):format(cmd, env)
			end
		end)
		typeset(img, ctx)
	end

	local placement = require("snacks.image.placement")

	-- Draw all math at one scale, a strut to a row, so inline formulas and blocks
	-- match. Snacks fits each trimmed image to a row on its own: a lone `a` or `-`
	-- filled the row while `\chi^2_{f,\alpha}` shrank, and blocks came out larger.
	local state = placement.state
	function placement:state()
		local ret = state(self)
		local kind = self.img.src:match("%.(math%a*)%.tex$")
		local info = self.img.info
		if not (kind and info and info.size.height > 0 and info.dpi.height > 0) then
			return ret
		end
		local cell = Snacks.image.terminal.size()
		local rows = info.size.height / info.dpi.height * 72 / row_pt
		local cols = info.size.width / info.dpi.width * 72 / row_pt * cell.cell_height / cell.cell_width
		if kind == "mathinline" then
			cols, rows = cols / rows, 1
		end
		local max_cols = self.opts.max_width or vim.o.columns
		for _, win in ipairs(ret.wins) do
			max_cols = math.min(max_cols, vim.api.nvim_win_get_width(win))
		end
		if cols > max_cols then
			cols, rows = max_cols, rows * max_cols / cols
		end
		ret.loc.width, ret.loc.height = math.ceil(cols), math.ceil(rows)
		return ret
	end

	-- An inline formula is drawn over its source, see over_source(). A revealed math
	-- block shows its whole source with the result below it. Snacks blanked the image
	-- and kept the extra source lines concealed, so only the first line and the cursor
	-- line of a multi-line block were visible.
	local render = placement._render
	function placement:_render(extmarks)
		if not self.hidden then
			if self.img.src:find("%.mathinline%.tex$") then
				extmarks = over_source(self.buf, extmarks)
			end
			return render(self, extmarks)
		end
		for _, e in ipairs(extmarks) do
			e.conceal_lines = nil
		end
		if not is_block(self) then
			return render(self, extmarks)
		end
		local rows = {} ---@type string[][]
		for _, e in ipairs(extmarks) do
			for _, line in ipairs(e.virt_text and { e.virt_text } or e.virt_lines or {}) do
				for _, chunk in ipairs(line) do
					if chunk[2] and chunk[2]:find("^SnacksImage%d") then
						rows[#rows + 1] = chunk
					end
				end
			end
		end
		local r = self.opts.range
		local pad = { string.rep(" ", r[2]) }
		self.hidden = false -- or render() blanks the preview too
		render(self, {
			-- spans the source, so the cursor is found inside the block
			{ row = r[1] - 1, col = r[2], end_row = r[3] - 1, end_col = r[4] },
			{
				row = r[3] - 1,
				col = 0,
				virt_lines = vim.tbl_map(function(chunk)
					return { pad, chunk }
				end, rows),
			},
		})
		self.hidden = true
	end

	local inline = require("snacks.image.inline")

	-- Only the formula under the cursor, or in the selection, shows its source. Snacks
	-- revealed every formula on the cursor line.
	function inline:conceal()
		local sel = revealed()
		for _, img in pairs(self.imgs) do
			if img.opts.conceal and is_revealed(img, sel) then
				img:hide()
			else
				img:show()
			end
		end
	end

	-- Snacks reveals on CursorMoved only; follow the cursor in insert mode too.
	local new = inline.new
	function inline.new(buf)
		local self = new(buf)
		vim.api.nvim_create_autocmd("CursorMovedI", {
			group = vim.api.nvim_create_augroup("snacks.image.inline." .. buf, { clear = false }),
			buffer = buf,
			callback = function()
				if buf == vim.api.nvim_get_current_buf() then
					self:conceal()
				end
			end,
		})
		return self
	end

	-- In insert mode, update once typing pauses and the changed formulas are compiled,
	-- swapping each new image in where the old one was. Snacks drops the old image
	-- first, which blanked a block's preview during every compile, and updating per
	-- keystroke compiled each half-typed formula.
	local update = inline.update
	function inline:update()
		if vim.api.nvim_get_mode().mode:sub(1, 1) ~= "i" then
			return update(self)
		end
		self.pending = (self.pending or 0) + 1
		local pending = self.pending
		local function current()
			return pending == self.pending and vim.api.nvim_buf_is_valid(self.buf)
		end
		vim.defer_fn(function()
			if not current() then
				return
			end
			Snacks.image.doc.find_visible(self.buf, function(found)
				local imgs = vim.tbl_map(function(i)
					return Snacks.image.image.new(i.src)
				end, found)
				local timer, waited = assert(vim.uv.new_timer()), 0
				timer:start(
					0,
					50,
					vim.schedule_wrap(function()
						waited = waited + 50
						local compiled = vim.iter(imgs):all(function(img)
							return img:ready() or img:failed()
						end)
						if timer:is_closing() or not (compiled or waited > 10000 or not current()) then
							return
						end
						timer:close()
						if current() then
							swap(self, found)
							update(self)
						end
					end)
				)
			end)
		end, 400)
	end
end

return M
