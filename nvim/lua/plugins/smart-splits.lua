return {
	"mrjones2014/smart-splits.nvim",
	config = function()
		require("smart-splits").setup({
			at_edge = "stop",
    })

		vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left)
		vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down)
		vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up)
		vim.keymap.set("n", "<C-l>", require("smart-splits").move_cursor_right)
	end,
}
