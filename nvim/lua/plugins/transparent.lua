return {
	"xiyaowong/transparent.nvim",
	config = function()
		require("transparent").setup({
			groups = {},
			extra_groups = {
				"TreesitterContext",
			},
		})
	end,
}
