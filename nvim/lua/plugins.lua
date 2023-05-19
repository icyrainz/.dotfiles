return {
	"nvim-lua/plenary.nvim",
	"MunifTanjim/nui.nvim",
	"nvim-tree/nvim-web-devicons",

	-- UI
	{
		"nvim-lualine/lualine.nvim",
		opts = function()
			return {
				options = { theme = "gruvbox-material" },
			}
		end,
	},
	{
		"akinsho/bufferline.nvim",
		config = true,
	},
	-- use 'ThePrimeagen/vim-be-good'

	-- Editor
	"tommcdo/vim-exchange",
	"tpope/vim-abolish",

	-- Quickfix
	"kevinhwang91/nvim-bqf",
	"kevinhwang91/promise-async",

	-- Others
	"stevearc/dressing.nvim",
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
