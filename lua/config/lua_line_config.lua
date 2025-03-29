require('lualine').setup {
	options = {
		icons_enabled = true,
		theme = 'auto',
		component_separators = { left = '', right = ''},
		section_separators = { left = '', right = ''},
		disabled_filetypes = {
			statusline = {},
			winbar = {},
		},
		ignore_focus = {},
		always_divide_middle = true,
		globalstatus = false,
		refresh = {
			statusline = 100,
			tabline = 100,
			winbar = 100,
		},
		always_show_tabline = true,
	},
	sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {},
		lualine_x = {},
		lualine_y = {},
		lualine_z = {},
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {'filename'},
		lualine_x = {'location'},
		lualine_y = {},
		lualine_z = {}
	},
	tabline = {
		lualine_a = {'filename'},
		lualine_b = {'filetype', 'fileformat', 'encoding'},
		lualine_c = {
			'datetime'

		},
		lualine_x = {'progress','location',
		{
			"tabs",
			cond = function()
				return #vim.fn.gettabinfo() > 1
			end,
		}
	},
	lualine_y = {'diagnostics','diff', 'branch'},
	lualine_z = {'searchcount', 'selectioncount', 'mode'}
},
winbar = {},
inactive_winbar = {},
extensions = {}
}
