return {
  enabled = false,
	"xiyaowong/transparent.nvim",
	config = function()
		require("transparent").setup({
			extra_groups = {
			},
		})
	end,
}
