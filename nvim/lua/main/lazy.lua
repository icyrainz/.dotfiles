local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
	"nvim-lua/plenary.nvim",
	"MunifTanjim/nui.nvim",
	"nvim-tree/nvim-web-devicons",
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.1",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	-- "rebelot/kanagawa.nvim",
  {
    "Alexis12119/nightly.nvim",
    config = function()
      require("nightly").setup({
        transparent = true,
      })
    end,
  },
	"tpope/vim-fugitive",
	"nvim-treesitter/nvim-treesitter",
	"nvim-treesitter/nvim-treesitter-context",
	-- use 'nvim-treesitter/nvim-treesitter-textobjects'
	"williamboman/mason.nvim",
	"neovim/nvim-lspconfig",
	"williamboman/mason-lspconfig.nvim",
	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v2.x",
	},
	"WhoIsSethDaniel/mason-tool-installer.nvim",
	"hrsh7th/nvim-cmp",
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-path",
	-- use 'hrsh7th/cmp-buffer'
	"L3MON4D3/LuaSnip",
	"saadparwaiz1/cmp_luasnip",
	"jose-elias-alvarez/null-ls.nvim",
	"simrat39/rust-tools.nvim",
	"rust-lang/rust.vim",
	{
		"saecki/crates.nvim",
		tag = "v0.3.0",
	},
	"jose-elias-alvarez/typescript.nvim",
	"MunifTanjim/prettier.nvim",
	"mfussenegger/nvim-dap",
	"theHamsta/nvim-dap-virtual-text",
	"rcarriga/nvim-dap-ui",
	-- use 'nvim-tree/nvim-tree.lua'
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v2.x",
	},
	"mbbill/undotree",
	"voldikss/vim-floaterm",
	{
		"akinsho/toggleterm.nvim",
		version = "*",
	},
	-- use "lukas-reineke/indent-blankline.nvim"
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require('lualine').setup({
        options = { theme = 'nightly' }
      })
    end,
  },
	{
	  "akinsho/bufferline.nvim",
    config = true,
	},
  {
    "tiagovla/scope.nvim",
    config = true,
  },
	-- use "github/copilot.vim"
	"zbirenbaum/copilot.lua",
	"zbirenbaum/copilot-cmp",
	-- use 'ThePrimeagen/vim-be-good'
  {
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup({
        manual_mode = true,
      })
    end,
  },
  {
    "AckslD/nvim-neoclip.lua",
    config = true,
  },
	"stevearc/dressing.nvim",
	"folke/which-key.nvim",
	"tommcdo/vim-exchange",
	"tpope/vim-abolish",
  {
    "folke/trouble.nvim",
    config = true,
  },
	"echasnovski/mini.nvim",
	"tamago324/lir.nvim",
  {
    "lewis6991/gitsigns.nvim",
    config = true,
  },
	"weilbith/nvim-code-action-menu",
	"alexghergh/nvim-tmux-navigation",
  {
    "simrat39/symbols-outline.nvim",
    config = true,
  },
	"kevinhwang91/nvim-bqf",
	"kevinhwang91/nvim-hlslens",
	"kevinhwang91/promise-async",
	"kevinhwang91/nvim-ufo",
  {
    "stevearc/qf_helper.nvim",
    config = true,
  },
  {
    "folke/todo-comments.nvim",
    config = true,
  },
}

local opts = {}

require("lazy").setup(plugins, opts)
