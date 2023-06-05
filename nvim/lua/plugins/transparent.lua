return {
  enabled = false,
	"xiyaowong/transparent.nvim",
	config = function()
		require("transparent").setup({
			extra_groups = {
				-- "TreesitterContext",
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
