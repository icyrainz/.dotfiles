return {
	"pwntester/octo.nvim",
  event = "VeryLazy",
	requires = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
		"kyazdani42/nvim-web-devicons",
	},
	config = function()
		require("octo").setup()
	end,
}
