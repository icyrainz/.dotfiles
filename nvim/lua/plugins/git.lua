return {
	"tpope/vim-fugitive",
	{
		"lewis6991/gitsigns.nvim",
		config = true,
	},
	{
		"akinsho/git-conflict.nvim",
		version = "*",
		config = true,
	},
	{
		"ThePrimeagen/git-worktree.nvim",
		config = function()
			require("git-worktree").setup()

			local telescope = require("telescope")
			telescope.load_extension("git_worktree")

			vim.keymap.set("n", "<leader>gwa", function()
				telescope.extensions.git_worktree.create_git_worktree()
			end, { desc = "Git worktree add" })

			vim.keymap.set("n", "<leader>gww", function()
				telescope.extensions.git_worktree.git_worktrees()
			end, { desc = "Git worktree telescope" })
		end,
	},
	{
		"f-person/git-blame.nvim",
		config = function()
			vim.g.gitblame_display_virtual_text = 0 -- Disable virtual text
			local git_blame = require("gitblame")

			local ok, lualine = pcall(require, "lualine")

			if ok then
				lualine.setup({
					sections = {
						lualine_c = {
							{ git_blame.get_current_blame_text, cond = git_blame.is_blame_text_available },
						},
					},
				})
			else
				print("lualine not found")
			end

			vim.keymap.set("n", "<leader>gbf", "<cmd>GitBlameCopyFileURL<CR>", { desc = "Git blame copy file URL" })
			vim.keymap.set("n", "<leader>gbc", "<cmd>GitBlameCopyCommitURL<CR>", { desc = "Git blame copy commit URL" })
		end,
	},
}
