return {
	"stevearc/qf_helper.nvim",
  config = true,
	init = function()
		vim.keymap.set("n", "<leader>q", ":QFToggle<CR>", { desc = "Close quickfix" })
	end,
}
