return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    incremental_selection = {
      keymaps = {
        init_selection = "<CR>",
        node_incremental = "<CR>",
        node_decremental = "<C-CR>",
      },
    },
  },
}
