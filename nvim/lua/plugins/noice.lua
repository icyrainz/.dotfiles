return {
	"folke/noice.nvim",
	config = function()
		require("noice").setup({})
	end,
	dependencies = {
		-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
		"MunifTanjim/nui.nvim",
	},
}
