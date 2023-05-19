return {
	"rebelot/kanagawa.nvim",
	"folke/tokyonight.nvim",
	{ "catppuccin/nvim", name = "catppuccin" },
	{
		"Alexis12119/nightly.nvim",
		opts = function()
			return {
				transparent = true,
			}
		end,
	},
	{
		"sainnhe/gruvbox-material",
		config = function()
      vim.g.gruvbox_material_background = 'hard'
      vim.g.gruvbox_material_foreground = 'mix'
      vim.g.gruvbox_material_better_performance = 1

			vim.cmd.colorscheme("gruvbox-material")
		end,
	},
}
