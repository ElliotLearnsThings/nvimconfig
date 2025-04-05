
local M = {}

-- Just a simple Dvorak layout for neovim
-- Replace all normal mode keys with their Dvorak equivalents

function M.set_dvorak_map(self)


-- Part 1 Basic remaps:
--
-- zx -> () done
-- cv -> {} done
-- S-z, S-x -> [] done
-- fn - <Tab> -> ! done
--
-- Part 2 custom symbols:
--
-- fn - qwerQWER -> ~"'`!$&* 
-- To do this its a bit more complex
-- remap qwer to keys that are symbols with multipe values
-- we choose:
-- fn q -> = -> +
-- fn w -> - -> _
-- fn e -> ' -> @
-- fn r -> # -> ~
--
-- Then in nvim:
-- = -> ~, + -> !
-- - -> ", _ -> $
-- ' -> ', @ -> &
-- # -> `, ~ -> *
--
-- Part 3 - Other numeric symbol remaps:
--
-- Remap    --- Eqiv in vim
-- S-0 -> ; --- ) -> ;
-- S-1 -> = --- ! -> =
-- S-2 -> - --- " -> -
-- S-3 -> _ --- £ -> _
-- S-4 -> + --- $ -> +
-- S-5 -> : --- % -> :
-- S-6 -> ? --- ^ -> ?
-- S-7 -> / --- & -> /
-- S-8 -> \ --- * -> \
-- S-9 -> | --- ( -> |
-- 
-- Part 4 - Layout spesific remaps:
-- remap using leader
-- - -> <leader>'
-- # -> ^ <leader>#
-- S-- -> @ <leader>@
--
--
--


	self.map = {
		-- Lowercase letters
		-- {'i', 'a',      "'", {noremap = true}},
		{'i', 'b',      "x", {noremap = true}},
		{'i', 'c',      "j", {noremap = true}},
		{'i', 'd',      "e", {noremap = true}},
		{'i', 'e',      ".", {noremap = true}},
		{'i', 'f',      "u", {noremap = true}},
		{'i', 'g',      "i", {noremap = true}},
		{'i', 'h',      "d", {noremap = true}},
		{'i', 'i',      "c", {noremap = true}},
		{'i', 'j',      "h", {noremap = true}},
		{'i', 'k',      "t", {noremap = true}},
		{'i', 'l',      "n", {noremap = true}},
		{'i', 'm',      "m", {noremap = true}},
		{'i', 'n',      "b", {noremap = true}},
		{'i', 'o',      "r", {noremap = true}},
		{'i', 'p',      "l", {noremap = true}},
		{'i', 'q',      "'", {noremap = true}},
		{'i', 'r',      "p", {noremap = true}},
		{'i', 's',      "o", {noremap = true}},
		{'i', 't',      "y", {noremap = true}},
		{'i', 'u',      "g", {noremap = true}},
		{'i', 'v',      "k", {noremap = true}},
		{'i', 'w',      ",", {noremap = true}},
		{'i', 'x',      "q", {noremap = true}},
		{'i', 'y',      "f", {noremap = true}},
		{'i', 'z',      ";", {noremap = true}},

		-- Uppercase letters (shift variants)
		-- {'i', 'A',      "\"", {noremap = true}},
		{'i', 'B',      "X", {noremap = true}},
		{'i', 'C',      "J", {noremap = true}},
		{'i', 'D',      "E", {noremap = true}},
		{'i', 'E',      ">", {noremap = true}},
		{'i', 'F',      "U", {noremap = true}},
		{'i', 'G',      "I", {noremap = true}},
		{'i', 'H',      "D", {noremap = true}},
		{'i', 'I',      "C", {noremap = true}},
		{'i', 'J',      "H", {noremap = true}},
		{'i', 'K',      "T", {noremap = true}},
		{'i', 'L',      "N", {noremap = true}},
		{'i', 'M',      "M", {noremap = true}},
		{'i', 'N',      "B", {noremap = true}},
		{'i', 'O',      "R", {noremap = true}},
		{'i', 'P',      "L", {noremap = true}},
		{'i', 'Q',      "\"", {noremap = true}},
		{'i', 'R',      "P", {noremap = true}},
		{'i', 'S',      "O", {noremap = true}},
		{'i', 'T',      "Y", {noremap = true}},
		{'i', 'U',      "G", {noremap = true}},
		{'i', 'V',      "K", {noremap = true}},
		{'i', 'W',      "<", {noremap = true}},
		{'i', 'X',      "Q", {noremap = true}},
		{'i', 'Y',      "F", {noremap = true}},
		{'i', 'Z',      ":", {noremap = true}},

		-- Special character mappings
		{'i', '[',      "/", {noremap = true}},
		{'i', ']',      "=", {noremap = true}},
		{'i', '{',      "?", {noremap = true}},  -- Shift variant of [
		{'i', '}',      "+", {noremap = true}},  -- Shift variant of ]
		{'i', ';',      "s", {noremap = true}},
		{'i', ':',      "S", {noremap = true}},  -- Shift variant of ;
		{'i', "'",      "-", {noremap = true}},
		{'i', '"',      "_", {noremap = true}},  -- Shift variant of '
		{'i', ',',      "w", {noremap = true}},
		{'i', '<',      "W", {noremap = true}},  -- Shift variant of ,
		{'i', '.',      "v", {noremap = true}},
		{'i', '>',      "V", {noremap = true}},  -- Shift variant of .
		{'i', '/',      "z", {noremap = true}},
		{'i', '?',      "Z", {noremap = true}},  -- Shift variant of /
		{'i', '-',      "[", {noremap = true}},
		{'i', '_',      "{", {noremap = true}},  -- Shift variant of -
		{'i', '=',      "]", {noremap = true}},
		{'i', '+',      "}", {noremap = true}},  -- Shift variant of =
		{'i', '1',      "1", {noremap = true}},
		{'i', '!',      "!", {noremap = true}},  -- Shift variant of 1
		{'i', '2',      "2", {noremap = true}},
		{'i', '@',      "@", {noremap = true}},  -- Shift variant of 2
		{'i', '3',      "3", {noremap = true}},
		{'i', '#',      "#", {noremap = true}},  -- Shift variant of 3
		{'i', '4',      "4", {noremap = true}},
		{'i', '$',      "$", {noremap = true}},  -- Shift variant of 4
		{'i', '5',      "5", {noremap = true}},
		{'i', '%',      "%", {noremap = true}},  -- Shift variant of 5
		{'i', '6',      "6", {noremap = true}},
		{'i', '^',      "^", {noremap = true}},  -- Shift variant of 6
		{'i', '7',      "7", {noremap = true}},
		{'i', '&',      "&", {noremap = true}},  -- Shift variant of 7
		{'i', '8',      "8", {noremap = true}},
		{'i', '*',      "*", {noremap = true}},  -- Shift variant of 8
		{'i', '9',      "9", {noremap = true}},
		{'i', '(',      "(", {noremap = true}},  -- Shift variant of 9
		{'i', '0',      "0", {noremap = true}},
		{'i', ')',      ")", {noremap = true}},  -- Shift variant of 0	}
	}

	-- no idea why this needs an empty string but do not trust changing it
	self.original_map = {
		""
	}

	if M.debug then
		vim.notify("[Dvorak] Original map: " .. vim.inspect(self.original_map), vim.log.levels.DEBUG)
	end

	if vim.tbl_isempty(self.original_map) == true then
		if M.debug then
			vim.notify("[Dvorak] No original map found", vim.log.levels.ERROR)
		end
		self.is_valid = false
		return
	end

	M.is_valid = true
end

function M.setup(opts)

	M.debug = opts.debug or false

	M.is_active = false
	M.set_dvorak_map(M)

	if M.is_valid == false then
		return
	end

	-- Bind the keys to switch between dvorak modes
	local keymap = opts.keymap

	vim.api.nvim_create_user_command("Dvorak", function()

		if M.is_valid == false then
			vim.notify("[Dvorak] Dvorak mode not valid", vim.log.levels.ERROR)
			return
		end

		M.setmap()
		M.is_active = true
		vim.notify("[Dvorak] Dvorak mode enabled", vim.log.levels.INFO)
	end, { nargs = 0 })

	vim.api.nvim_create_user_command("DvorakUndo", function()

		if M.is_valid == false then
			vim.notify("[Dvorak] Dvorak mode not valid", vim.log.levels.ERROR)
			return
		end

		M.undomap()
		M.is_active = false
		vim.notify("[Dvorak] Dvorak mode disabled", vim.log.levels.INFO)
	end, { nargs = 0 })

	vim.api.nvim_create_user_command("DvorakToggle", function ()

		if M.is_valid == false then
			vim.notify("[Dvorak] Dvorak mode not valid", vim.log.levels.ERROR)
			return
		end

		if M.is_active then
			M.undomap()
			M.is_active = false
			vim.notify("[Dvorak] Dvorak mode disabled", vim.log.levels.INFO)
		else
			M.setmap()
			M.is_active = true
			vim.notify("[Dvorak] Dvorak mode enabled", vim.log.levels.INFO)
		end
	end, { nargs = 0 })


	-- Set up the key mapping
	if keymap ~= nil then
		vim.keymap.set("n", keymap, "<CMD>DvorakToggle<CR>", { noremap = true, silent = true })
	end
end

function M.setmap ()
	if M.is_active then
		return
	end

	for _, map in ipairs(M.map) do
		local mode, lhs, rhs, opts = unpack(map)
		vim.keymap.set(mode, lhs, rhs, opts)
	end
end

function M.undomap ()

	if not M.is_active then
		return
	end

-- there nothing

	for _, map in ipairs(M.map) do
		local mode, lhs, _, opts = unpack(map)
		if not (mode == nil or lhs == nil) then
			local original_map = M.original_map[lhs]
			if original_map ~= nil and original_map ~= "" then
				if M.debug then
					vim.notify("rhs" .. original_map)
				end
				vim.keymap.set(mode, lhs, original_map, opts)
			else
				vim.keymap.del(mode, lhs, opts)
			end
		end

	end
end

return M
