return {
  "nvim-lua/plenary.nvim",
  "MunifTanjim/nui.nvim",
  "nvim-tree/nvim-web-devicons",

  -- Editor
  {
    "tommcdo/vim-exchange",
    event = "VeryLazy",
  },
  {
    "tpope/vim-abolish",
    event = "VeryLazy",
  },

  "kevinhwang91/promise-async",

  {
    "junegunn/fzf",
    build = function()
      vim.fn['fzf#install']()
    end,
    event = "VeryLazy",
  },
}
