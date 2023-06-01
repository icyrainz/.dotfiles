return {
	{
		"folke/noice.nvim",
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
		config = function()
			require("noice").setup({
				lsp = {
					-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
					override = {
						["vim.lsp.util.convert_input_to_markdown_lines"] = true,
						["vim.lsp.util.stylize_markdown"] = true,
						["cmp.entry.get_documentation"] = true,
					},
				},
				presets = {
					bottom_search = true,
          long_message_to_split = false,
					lsp_doc_border = true,
				},
        cmdline = {
          view = "cmdline",
        },
			})
			require("telescope").load_extension("noice")

			vim.keymap.set("n", "<leader>fn", "<cmd>Telescope noice<CR>", { desc = "[Telescope] noice" })
		end,
	},
}
