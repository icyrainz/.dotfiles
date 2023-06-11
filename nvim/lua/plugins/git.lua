return {
	{
	  "tpope/vim-fugitive",
    cmd = "G",
	},
	{
		"lewis6991/gitsigns.nvim",
    event = "VeryLazy",
		config = true,
	},
	{
		"akinsho/git-conflict.nvim",
    event = "VeryLazy",
		config = true,
	},
	{
		"ThePrimeagen/git-worktree.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    keys = {
      { "<leader>gwa", function() require("telescope").extensions.git_worktree.create_git_worktree() end, desc = "Git worktree add"},
      { "<leader>gww", function() require("telescope").extensions.git_worktree.git_worktrees() end, desc = "Git worktrees"},
    },
		config = function()
			local telescope = require("telescope")
			telescope.load_extension("git_worktree")
		end,
	},
	{
		"f-person/git-blame.nvim",
    keys = {
      { "<leader>gbf", "<cmd>GitBlameCopyFileURL<CR>", desc = "Git blame copy file URL" },
      { "<leader>gbc", "<cmd>GitBlameCopyCommitURL<CR>", desc = "Git blame copy commit URL" },
    },
		init = function()
			vim.g.gitblame_display_virtual_text = 0 -- Disable virtual text
		end,
	},
}
