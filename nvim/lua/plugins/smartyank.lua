return {
	"ibhagwan/smartyank.nvim",
	config = function()
		require("smartyank").setup({
			clipboard = {
				enabled = false,
			},
		})
	end,
}
