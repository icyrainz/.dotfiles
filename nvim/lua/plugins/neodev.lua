return {
	"folke/neodev.nvim",
	dependencies = {
		"neovim/nvim-lspconfig",
	},
  ft = { "lua" },
	opts = {
		library = { plugins = { "nvim-dap.ui" }, types = true },
	},
}
