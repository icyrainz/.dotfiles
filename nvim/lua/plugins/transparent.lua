return {
	"xiyaowong/transparent.nvim",
	config = function()
		require("transparent").setup({
			groups = nil,
			extra_groups = {
				"TreesitterContext",
        "MiniTablineFill",
        "MiniTablineHidden",
        "MiniStatuslineFilename",
        "MiniStatuslineFileinfo",
        "MiniStatuslineDevinfo",
        "MiniStatuslineInactive",
			},
		})
	end,
}
