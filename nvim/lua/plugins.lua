return {
	"nvim-lua/plenary.nvim",
	"MunifTanjim/nui.nvim",
	"nvim-tree/nvim-web-devicons",

	-- UI
	{
		"akinsho/bufferline.nvim",
		config = true,
	},
	-- use 'ThePrimeagen/vim-be-good'

	-- Editor
	"tommcdo/vim-exchange",
	"tpope/vim-abolish",
	-- "chaoren/vim-wordmotion",
  "chrisgrieser/nvim-spider",

	-- Quickfix
	"kevinhwang91/nvim-bqf",
	"kevinhwang91/promise-async",

	-- Others
	{
		"folke/todo-comments.nvim",
		config = true,
	},
	{
		"junegunn/fzf",
		build = function()
			vim.fn["fzf#install"]()
		end,
	},
}
