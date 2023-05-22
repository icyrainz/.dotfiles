return {
	"saifulapm/chartoggle.nvim",
	config = function()
		require("chartoggle").setup({
			leader = "<leader>", -- you can use any key as Leader
			keys = { ",", ";" }, -- Which keys will be toggle end of the line
		})
	end,
}
