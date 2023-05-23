return {
	"folke/neodev.nvim",
	dependencies = {
		"neovim/nvim-lspconfig",
	},
	opts = {
		library = { plugins = { "nvim-dap.ui" }, types = true },
	},
}
