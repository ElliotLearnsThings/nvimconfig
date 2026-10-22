-- Native multicursor (Neovim 0.13+, `:h multicursor`).
--
-- Core gives Q (toggle cursor), zq{motion} (cursor at every motion target),
-- {Visual}Q (cursor per line), q= (follow mode), ]C / [C (jump between
-- cursors), CTRL-L (clear), gQ (restore).
--
-- multicursor-mappings.nvim adds convenience maps on top:
--   <M-n> / <M-S-n>  cursor here, jump to next / prev match of word or selection
--   {Visual}<M-a>    cursor at every match of the selection
--   <M-m>            jump back to the previous cursor and remove it
--   <M-=>            toggle follow mode
--   <Esc>, <M-i>     clear cursors
--
-- Its Normal-mode <M-a>, <M-j>, <M-k> are shadowed by buf_switch_2 (<A-a>..<A-l>),
-- which is required after lazy.setup. Core equivalents: zq* (every match of the
-- word), Qj / Qk, or V{motion}Q (a cursor per line).

return {
	{
		"jceb/multicursor-mappings.nvim",
		cond = vim.fn.has("nvim-0.13") == 1,
		init = function()
			-- vim.api.nvim_mcursor was dropped from nightly in favour of setting extmarks
			-- in the "nvim.multicursor" namespace (neovim#42156), but the plugin still
			-- calls it. Remove once upstream stops using it.
			if not vim.api.nvim_mcursor then
				local ns = vim.api.nvim_create_namespace("nvim.multicursor")
				---@param pos [integer, integer] (1,0)-indexed, as from nvim_win_get_cursor
				vim.api.nvim_mcursor = function(buf, pos)
					vim.api.nvim_buf_set_extmark(buf, ns, pos[1] - 1, pos[2], {})
				end
			end
		end,
	},
}
