return {
  "nvim-lua/plenary.nvim",
  "MunifTanjim/nui.nvim",
  "nvim-tree/nvim-web-devicons",

  -- Themes
  -- "rebelot/kanagawa.nvim",
  {
    "Alexis12119/nightly.nvim",
    opts = function()
      return {
        transparent = true,
      }
    end,
  },

  -- Git
  "tpope/vim-fugitive",
  {
    "lewis6991/gitsigns.nvim",
    config = true,
  },

  -- Treesitter
  "nvim-treesitter/nvim-treesitter",
  "nvim-treesitter/nvim-treesitter-context",
  -- use 'nvim-treesitter/nvim-treesitter-textobjects'

  -- Autocompletion
  { 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'L3MON4D3/LuaSnip' },

  -- Rust stuffs
  {
    "saecki/crates.nvim",
    tag = "v0.3.0",
  },

  -- Linter
  "MunifTanjim/prettier.nvim",

  -- Debugger
  "theHamsta/nvim-dap-virtual-text",
  "rcarriga/nvim-dap-ui",

  -- File explorer
  -- use 'nvim-tree/nvim-tree.lua'
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
  },
  "tamago324/lir.nvim",

  -- Terminal
  "voldikss/vim-floaterm",
  {
    "akinsho/toggleterm.nvim",
    version = "*",
  },
  -- use "lukas-reineke/indent-blankline.nvim"

  -- UI
  {
    "nvim-lualine/lualine.nvim",
    opts = function()
      return {
        options = { theme = 'nightly' }
      }
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

  -- Copilot
  -- use "github/copilot.vim"
  "zbirenbaum/copilot.lua",
  -- "zbirenbaum/copilot-cmp",

  -- use 'ThePrimeagen/vim-be-good'

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.1",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
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

  -- Editor
  "tommcdo/vim-exchange",
  "tpope/vim-abolish",

  -- Quickfix
  "kevinhwang91/nvim-bqf",
  "kevinhwang91/promise-async",
  {
    "stevearc/qf_helper.nvim",
    config = true,
  },

  -- Keybind helpers
  "folke/which-key.nvim",

  -- Tools
  "mbbill/undotree",
  {
    "folke/trouble.nvim",
    config = true,
  },
  {
    "simrat39/symbols-outline.nvim",
    config = true,
  },

  -- Others
  "kevinhwang91/nvim-hlslens",
  "stevearc/dressing.nvim",
  "echasnovski/mini.nvim",
  "weilbith/nvim-code-action-menu",
  "alexghergh/nvim-tmux-navigation",
  "kevinhwang91/nvim-ufo",
  {
    "folke/todo-comments.nvim",
    config = true,
  },
}
