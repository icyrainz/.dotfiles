return {
	"stevearc/dressing.nvim",
	config = function()
		require("dressing").setup({
			select = {
				backend = { "fzf_lua", "telescope" },
			},
		})
	end,
}
