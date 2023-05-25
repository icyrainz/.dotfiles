return {
	"folke/neodev.nvim",
  ft = {
    "lua"
  },
	dependencies = {
		"neovim/nvim-lspconfig",
	},
	opts = {
		library = { plugins = { "nvim-dap.ui" }, types = true },
	},
}
