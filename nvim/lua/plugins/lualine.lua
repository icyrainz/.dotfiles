return {
	{
		"nvim-lualine/lualine.nvim",
		opts = {
			options = {
				theme = function()
					local colors = {
						darkgray = "#16161d",
						gray = "#727169",
						innerbg = nil,
						outerbg = "#16161d",
						normal = "#7e9cd8",
						insert = "#98bb6c",
						visual = "#9745be",
						replace = "#e46876",
						command = "#e6c384",
					}
					return {
						inactive = {
							a = { fg = colors.gray, bg = colors.outerbg, gui = "bold" },
							b = { fg = colors.gray, bg = colors.outerbg },
							c = { fg = colors.gray, bg = colors.innerbg },
						},
						visual = {
							a = { fg = colors.darkgray, bg = colors.visual, gui = "bold" },
							b = { fg = colors.gray, bg = colors.outerbg },
							c = { fg = colors.gray, bg = colors.innerbg },
						},
						replace = {
							a = { fg = colors.darkgray, bg = colors.replace, gui = "bold" },
							b = { fg = colors.gray, bg = colors.outerbg },
							c = { fg = colors.gray, bg = colors.innerbg },
						},
						normal = {
							a = { fg = colors.darkgray, bg = colors.normal, gui = "bold" },
							b = { fg = colors.gray, bg = colors.outerbg },
							c = { fg = colors.gray, bg = colors.innerbg },
						},
						insert = {
							a = { fg = colors.darkgray, bg = colors.insert, gui = "bold" },
							b = { fg = colors.gray, bg = colors.outerbg },
							c = { fg = colors.gray, bg = colors.innerbg },
						},
						command = {
							a = { fg = colors.darkgray, bg = colors.command, gui = "bold" },
							b = { fg = colors.gray, bg = colors.outerbg },
							c = { fg = colors.gray, bg = colors.innerbg },
						},
					}
				end,
				section_separators = "",
				component_separators = "",
			},
			extensions = {
				"lazy",
				"neo-tree",
				"fugitive",
				"quickfix",
				"symbols-outline",
				"nvim-dap-ui",
				"trouble",
			},
		},
	},
}
