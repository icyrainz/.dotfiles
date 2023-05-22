return {
	{
		"jackMort/ChatGPT.nvim",
    enabled = os.getenv("USE_AI_TOOLS") == "true",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			require("chatgpt").setup({
				popup_input = {
					submit = "<CR>",
					submit_n = "<A-CR>",
				},
			})

			vim.keymap.set("n", "<leader>mc", ":ChatGPT<CR>", {
				desc = "ChatGPT",
			})
			vim.keymap.set("n", "<leader>me", ":ChatGPTEditWithInstructions<CR>", {
				desc = "ChatGPT Edit (all)",
			})

			vim.keymap.set("v", "<leader>me", function()
				require("chatgpt").edit_with_instructions()
			end, {
				desc = "ChatGPT Edit (selected)",
				silent = true,
			})
		end,
	},
}
