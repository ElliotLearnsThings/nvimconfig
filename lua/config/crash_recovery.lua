-- Make swap recovery bring back unsaved edits *with* their undo history.
--
-- Nvim keeps two separate records of a buffer:
--   * the swap file holds the text, unsaved edits included. It is synced when
--     you stop typing for 'updatetime' ms (and every 'updatecount' chars), and
--     it is kept when Nvim crashes or its terminal is closed.
--   * the undo file ('undofile') holds the undo tree, but is only written on :w.
-- So after a crash, (R)ecover restores the text while undotree knows nothing
-- about the edits that were never saved (`nvim -r` even starts with no undo
-- history at all). To close that gap, the undo tree of every modified buffer is
-- also written to a side directory whenever the swap file is synced, and read
-- back after a recovery. An undo file records a hash of the text it belongs to,
-- so :rundo only accepts it when the recovered text matches.

local group = vim.api.nvim_create_augroup("crash_recovery", { clear = true })

vim.o.undofile = true

local dir = vim.fn.stdpath("state") .. "/undo-unsaved/"
vim.fn.mkdir(dir, "p")

-- Same naming scheme as 'undodir' with a trailing "//": the full path with
-- every "/" replaced by "%".
local function shadow_path(buf)
	return dir .. (vim.api.nvim_buf_get_name(buf):gsub("/", "%%"))
end

-- Real files with unsaved changes that a swap file can recover.
local function has_unsaved_edits(buf)
	local bo = vim.bo[buf]
	return vim.api.nvim_buf_is_loaded(buf)
		and bo.buftype == ""
		and bo.modified
		and bo.undofile
		and bo.swapfile
		and vim.api.nvim_buf_get_name(buf) ~= ""
end

local written = {} -- buf -> changedtick at the last write

-- CursorHold(I) fires on the same 'updatetime' idle tick that syncs swap files,
-- so the history written here matches the text a crash would leave behind.
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
	group = group,
	desc = "Write the undo history of unsaved edits next to the swap sync",
	callback = function()
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			local tick = vim.api.nvim_buf_get_changedtick(buf)
			if written[buf] ~= tick and has_unsaved_edits(buf) then
				vim.api.nvim_buf_call(buf, function()
					vim.cmd("silent! wundo! " .. vim.fn.fnameescape(shadow_path(buf)))
				end)
				written[buf] = tick
			end
		end
	end,
})

-- Once the file is written, its real undo file has the whole history.
vim.api.nvim_create_autocmd("BufWritePost", {
	group = group,
	callback = function(ev)
		os.remove(shadow_path(ev.buf))
		written[ev.buf] = nil
	end,
})

vim.api.nvim_create_autocmd("BufWipeout", {
	group = group,
	callback = function(ev)
		written[ev.buf] = nil
	end,
})

-- A plain read leaves the buffer unmodified. When the recovered text differs
-- from the file on disk, the BufReadPost that :recover fires sees a modified
-- buffer.

-- :recover swaps in the recovered text without notifying buffer listeners (no
-- on_lines, on_bytes or on_reload), so the treesitter parser attached when the
-- file was read kept parsing the text on disk: markdown drew tables and math on
-- the wrong lines, and render-markdown read past the end of the buffer.
vim.api.nvim_create_autocmd("BufReadPost", {
	group = group,
	desc = "After a swap recovery, reparse the recovered text with treesitter",
	callback = function(ev)
		if not vim.bo[ev.buf].modified then
			return
		end
		local parser = vim.treesitter.get_parser(ev.buf, nil, { error = false })
		if parser then
			parser:invalidate(true)
		end
	end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
	group = group,
	desc = "After a swap recovery, restore the undo history of the unsaved edits",
	callback = function(ev)
		if not has_unsaved_edits(ev.buf) then
			return
		end
		local path = shadow_path(ev.buf)
		if not vim.uv.fs_stat(path) then
			return
		end
		local before = vim.fn.undotree(ev.buf).seq_last
		vim.cmd("silent! rundo " .. vim.fn.fnameescape(path))
		if vim.fn.undotree(ev.buf).seq_last ~= before then
			vim.notify("Restored undo history for the recovered unsaved edits", vim.log.levels.INFO)
		end
	end,
})

-- Replaces Nvim's default handler (augroup nvim.swapfile), which silently picks
-- "(E)dit anyway" whenever the swap file's owner is still running. That hides
-- edits the other instance has not saved yet, and you end up looking at, and
-- possibly overwriting, an older copy of the file. Skip the prompt only when the
-- other instance has nothing unsaved.
vim.api.nvim_create_autocmd("SwapExists", {
	group = vim.api.nvim_create_augroup("nvim.swapfile", { clear = true }),
	desc = "Skip the swapfile prompt only when the owning Nvim has no unsaved changes",
	callback = function()
		local info = vim.fn.swapinfo(vim.v.swapname)
		local passwd = vim.uv.os_get_passwd()
		-- pid is 0 when the owner is no longer running, i.e. it crashed.
		if info.error or info.pid <= 0 or info.dirty == 1 or not passwd or info.user ~= passwd.username then
			vim.v.swapchoice = "" -- show the E325 prompt
			return
		end
		vim.v.swapchoice = "e"
		vim.notify(("W325: Ignoring swapfile from Nvim process %d"):format(info.pid), vim.log.levels.WARN)
	end,
})

-- Leftovers from sessions quit with :qa! are never read back (their hash no
-- longer matches anything); drop them after a while.
local cutoff = os.time() - 30 * 24 * 60 * 60
for name, type in vim.fs.dir(dir) do
	local stat = vim.uv.fs_stat(dir .. name)
	if type == "file" and stat and stat.mtime.sec < cutoff then
		os.remove(dir .. name)
	end
end
