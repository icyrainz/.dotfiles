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

  -- Autocompletion
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'L3MON4D3/LuaSnip' },

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
  -- use 'ThePrimeagen/vim-be-good'

  -- Editor
  "tommcdo/vim-exchange",
  "tpope/vim-abolish",

  -- Quickfix
  "kevinhwang91/nvim-bqf",
  "kevinhwang91/promise-async",

  -- Others
  "stevearc/dressing.nvim",
  "weilbith/nvim-code-action-menu",
  {
    "folke/todo-comments.nvim",
    config = true,
  },
}
