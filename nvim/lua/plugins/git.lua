return {
	"tpope/vim-fugitive",
	{
		"lewis6991/gitsigns.nvim",
		config = true,
	},
	{
	  "akinsho/git-conflict.nvim",
	  version = "*",
	  config = true
	},
	{
		"ldelossa/gh.nvim",
		dependencies = {
			"ldelossa/litee.nvim",
		},
		config = function()
			require("litee.lib").setup()
			require("litee.gh").setup()
		end,
	},
	{
		"f-person/git-blame.nvim",
		config = function()
			vim.g.gitblame_display_virtual_text = 0 -- Disable virtual text
			local git_blame = require("gitblame")

			require("lualine").setup({
				sections = {
					lualine_c = {
						{ git_blame.get_current_blame_text, cond = git_blame.is_blame_text_available },
					},
				},
			})

			vim.keymap.set("n", "<leader>gbf", "<cmd>GitBlameCopyFileURL<CR>", { desc = "Git blame copy file URL" })
			vim.keymap.set("n", "<leader>gbc", "<cmd>GitBlameCopyCommitURL<CR>", { desc = "Git blame copy commit URL" })
		end,
	},
}
