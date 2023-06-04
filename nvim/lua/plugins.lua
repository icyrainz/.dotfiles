return {
  "nvim-lua/plenary.nvim",
  "MunifTanjim/nui.nvim",
  "nvim-tree/nvim-web-devicons",

  -- Editor
  "tommcdo/vim-exchange",
  "tpope/vim-abolish",

  -- Quickfix
  "kevinhwang91/promise-async",

  {
    "junegunn/fzf",
    build = function()
      vim.fn['fzf#install']()
    end
  },
}
