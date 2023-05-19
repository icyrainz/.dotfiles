return {
	"ggandor/leap.nvim",
	config = function()
		vim.keymap.set({ "n", "x", "o" }, "<leader>lf", "<Plug>(leap-forward-to)")
    vim.keymap.set({ "n", "x", "o" }, "<leader>lt", "<Plug>(leap-forward-till)")
		vim.keymap.set({ "n", "x", "o" }, "<leader>lF", "<Plug>(leap-backward-to)")
		vim.keymap.set({ "n", "x", "o" }, "<leader>lT", "<Plug>(leap-backward-till)")
		vim.keymap.set({ "n", "x", "o" }, "<leader>lw", "<Plug>(leap-from-window)")
	end,
}
