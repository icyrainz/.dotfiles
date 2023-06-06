return {
	"ggandor/leap.nvim",
	config = function()
		vim.keymap.set({ "n", "x", "o" }, "<leader>l", "<Plug>(leap-forward-to)", { desc = "Leap forward" })
		-- vim.keymap.set({ "n", "x", "o" }, "<leader>lt", "<Plug>(leap-forward-till)")
		vim.keymap.set({ "n", "x", "o" }, "<leader>L", "<Plug>(leap-backward-to)", { desc = "Leap backward" })
		-- vim.keymap.set({ "n", "x", "o" }, "<leader>lT", "<Plug>(leap-backward-till)")
		-- vim.keymap.set({ "n", "x", "o" }, "<leader>lw", "<Plug>(leap-from-window)")
	end,
}
