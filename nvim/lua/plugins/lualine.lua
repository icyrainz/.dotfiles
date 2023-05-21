return {
	{
		"nvim-lualine/lualine.nvim",
		opts = function()
			return {
				options = {
					theme = "auto",
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
			}
		end,
	},
}
