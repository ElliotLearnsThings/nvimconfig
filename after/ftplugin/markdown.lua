-- Buffer-local markdown setup. Plugin specs are in lua/plugins/markdown.lua.

local opt = vim.opt_local
opt.conceallevel = 2      -- render-markdown needs this to hide raw syntax
opt.concealcursor = "nvic" -- keep the cursor line rendered; math reveals per formula
opt.wrap = true
opt.linebreak = true      -- wrap at word boundaries
opt.breakindent = true
opt.spell = true
opt.spelllang = "en_us,sv" -- notes mix both; sv.utf-8.spl lives in stdpath("data")/site/spell
opt.textwidth = 0
opt.shiftwidth = 2
opt.tabstop = 2
opt.expandtab = true

pcall(vim.treesitter.start)

-- render-markdown skips math silently when no converter is installed, so say it once.
if not vim.g.markdown_latex_checked then
	vim.g.markdown_latex_checked = true
	if vim.fn.executable("utftex") == 0 and vim.fn.executable("latex2text") == 0 then
		vim.notify("No LaTeX converter: install utftex (yay -S libtexprintf) or latex2text (uv tool install pylatexenc)", vim.log.levels.WARN)
	end
end

-- Math completion (\alpha -> α) only in markdown buffers.
local ok_cmp, cmp = pcall(require, "cmp")
if ok_cmp then
	-- From the global sources, since this can run twice for a buffer and
	-- cmp.get_config() would return the ones added the first time.
	local sources = vim.deepcopy(require("cmp.config").global.sources or {})
	table.insert(sources, 1, { name = "latex_symbols", priority = 130, group_index = 1, option = { strategy = 0 } })
	-- Spelling suggestions from both 'spelllang' languages, alongside buffer words.
	-- Only while 'spell' is on, so <leader>ts turns them off too.
	table.insert(sources, { name = "spell", keyword_length = 3, max_item_count = 5, priority = 85, group_index = 2 })
	cmp.setup.buffer({ sources = sources })
end

local map = function(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { buffer = true, silent = true, desc = desc })
end

map("n", "<leader>mm", function() require("nabla").popup({ border = "rounded" }) end, "Math: render formula under cursor")
map("n", "<leader>mv", function() require("nabla").toggle_virt({ autogen = true, silent = true }) end, "Math: toggle inline 2D rendering")
map("n", "<leader>mr", "<CMD>RenderMarkdown buf_toggle<CR>", "Markdown: toggle in-buffer rendering")
map("n", "<leader>mp", "<CMD>MarkdownPreviewToggle<CR>", "Markdown: toggle browser preview (KaTeX)")

-- Quick math insertion.
map("i", ";m", "$$<Left>", "Inline math")
map("i", ";M", "$$<CR>$$<Esc>O", "Display math block")

-- Toggle checkbox on the current line: "- [ ]" <-> "- [x]"; add one if missing.
map("n", "<leader>mx", function()
	local line = vim.api.nvim_get_current_line()
	local new
	if line:match("^%s*[-*+] %[ %]") then
		new = line:gsub("%[ %]", "[x]", 1)
	elseif line:match("^%s*[-*+] %[x%]") then
		new = line:gsub("%[x%]", "[ ]", 1)
	elseif line:match("^%s*[-*+] ") then
		new = line:gsub("^(%s*[-*+] )", "%1[ ] ", 1)
	else
		new = line:gsub("^(%s*)", "%1- [ ] ", 1)
	end
	vim.api.nvim_set_current_line(new)
end, "Markdown: toggle checkbox")

-- ]d / [d: jump to the next/previous misspelled word and list suggestions in a
-- float. j/k move, <CR> replaces the word, q/<Esc> closes. Overrides the global
-- diagnostic maps here, since spelling is what matters in notes.
local function spell_suggest()
	local bad = vim.fn.spellbadword()
	local word = bad[1]
	if word == "" then
		return vim.notify("No misspelled word", vim.log.levels.INFO)
	end
	local suggestions = vim.fn.spellsuggest(word, 10)
	if #suggestions == 0 then
		return vim.notify("No suggestions for '" .. word .. "'", vim.log.levels.INFO)
	end

	local target = vim.api.nvim_get_current_buf()
	local pos = vim.api.nvim_win_get_cursor(0)
	local row, col = pos[1] - 1, pos[2]

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, suggestions)
	vim.bo[buf].modifiable = false
	vim.bo[buf].bufhidden = "wipe"

	local width = #word + 2
	for _, s in ipairs(suggestions) do
		width = math.max(width, vim.fn.strdisplaywidth(s))
	end
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "cursor", row = 1, col = 0,
		width = width, height = #suggestions,
		style = "minimal", border = "rounded",
		title = " " .. word .. " ", title_pos = "center",
	})
	vim.wo[win].cursorline = true

	local function close()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end
	local function accept()
		local choice = suggestions[vim.api.nvim_win_get_cursor(win)[1]]
		close()
		vim.api.nvim_buf_set_text(target, row, col, row, col + #word, { choice })
		vim.api.nvim_win_set_cursor(0, { row + 1, col })
	end

	local o = { buffer = buf, nowait = true, silent = true }
	vim.keymap.set("n", "<CR>", accept, o)
	vim.keymap.set("n", "q", close, o)
	vim.keymap.set("n", "<Esc>", close, o)
	vim.api.nvim_create_autocmd("WinLeave", { buffer = buf, once = true, callback = close })
end

map("n", "]d", function() vim.cmd("normal! ]s") spell_suggest() end, "Spell: next misspelling + suggestions")
map("n", "[d", function() vim.cmd("normal! [s") spell_suggest() end, "Spell: previous misspelling + suggestions")
