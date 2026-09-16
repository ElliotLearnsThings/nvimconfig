-- Buffer-local markdown setup. Plugin specs are in lua/plugins/markdown.lua.

local opt = vim.opt_local
opt.conceallevel = 2      -- render-markdown needs this to hide raw syntax
opt.concealcursor = ""    -- reveal source on the cursor line
opt.wrap = true
opt.linebreak = true      -- wrap at word boundaries
opt.breakindent = true
opt.spell = true
opt.spelllang = "en_us"
opt.textwidth = 0
opt.shiftwidth = 2
opt.tabstop = 2
opt.expandtab = true

pcall(vim.treesitter.start)

-- Math completion (\alpha -> α) only in markdown buffers.
local ok_cmp, cmp = pcall(require, "cmp")
if ok_cmp then
	local sources = vim.deepcopy(cmp.get_config().sources or {})
	table.insert(sources, 1, { name = "latex_symbols", priority = 130, group_index = 1, option = { strategy = 0 } })
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
