-- Harpoon config
local M = {}

local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

vim.keymap.set("n", "<leader>a", mark.add_file)
vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu)

-- Custom navigation function that handles oil:/// paths correctly
local function nav_file_with_oil_fix(index)
	local file = mark.get_marked_file_name(index)

	if file and file:match("^oil:") then
		-- Ensure oil paths always have three slashes
		if not file:match("^oil:///") then
			file = file:gsub("^oil:/+", "oil:///")
		end

		-- Escape any special characters in the path
		file = vim.fn.fnameescape(file)

		-- Use Vim's edit command directly
		vim.cmd("edit " .. file)
	else
		-- Use default Harpoon navigation for non-oil files
		ui.nav_file(index)
	end
end

vim.keymap.set("n", "<F1>", function() nav_file_with_oil_fix(1) end)
vim.keymap.set("n", "<F2>", function() nav_file_with_oil_fix(2) end)
vim.keymap.set("n", "<F3>", function() nav_file_with_oil_fix(3) end)
vim.keymap.set("n", "<F4>", function() nav_file_with_oil_fix(4) end)
vim.keymap.set("n", "<F5>", function() nav_file_with_oil_fix(5) end)
vim.keymap.set("n", "<F6>", function() nav_file_with_oil_fix(6) end)

return M
--[[
local tab_marks = require("config.custom_harpoon.tab_marks")

-- Harpoon config
---@class Tab_mark
---@field mark any The mark associated with the tab
local Tab_mark = {}

---@param mark any The mark to associate with the tab
---@return Tab_mark A new Tab_mark instance
function Tab_mark.from_mark(mark)
	return { mark = mark }
end

---@class Harpoon_config
---@field marks Tab_marks a table of marks
local M = {}

---@return Harpoon_config
function M.on_load()
	local marks_list = tab_marks:new()
	-- Assumes on load we only have one tab
	marks_list:add(1, require"harpoon.mark")
	return setmetatable({marks = marks_list}, HarpoonConfig)
end

function M:on_change_tab(tabnr)
	-- Check if tabnr exists
	local mark = self.marks:get(tabnr)
	if mark == nil then
		mark = Tab_mark.from_mark(require"harpoon.mark")
	end

	-- Append to self
	self.marks:add(tabnr, mark)

	-- Set keybindings to new mark
	self.set_keybindings(mark)

end

function M.remove_keybindings()
	vim.keymap.del("n", "<leader>a")
	vim.keymap.del("n", "<C-1>")
	vim.keymap.del("n", "<C-2>")
	vim.keymap.del("n", "<C-3>")
	vim.keymap.del("n", "<C-4>")
	vim.keymap.del("n", "<C-5>")
	vim.keymap.del("n", "<C-6>")
end

---@param mark Tab_mark
function M.set_keybindings(mark)

	local ui = require("harpoon.ui")

	vim.keymap.set("n", "<leader>a", mark.mark.add_file)
	vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu)

	vim.keymap.set("n", "<C-1>", function() ui.nav_file(1) end)
	vim.keymap.set("n", "<C-2>", function() ui.nav_file(2) end)
	vim.keymap.set("n", "<C-3>", function() ui.nav_file(3) end)
	vim.keymap.set("n", "<C-4>", function() ui.nav_file(4) end)
	vim.keymap.set("n", "<C-5>", function() ui.nav_file(5) end)
	vim.keymap.set("n", "<C-6>", function() ui.nav_file(6) end)
end



return M
]]

