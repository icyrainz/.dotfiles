return {
	"stevearc/qf_helper.nvim",
	config = function()
		require("qf_helper").setup()

		vim.keymap.set("n", "<leader>q", ":QFToggle<CR>", { desc = "Close quickfix" })
	end,
}
