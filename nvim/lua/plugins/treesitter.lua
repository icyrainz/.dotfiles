return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    incremental_selection = {
      keymaps = {
        init_selection = "<C-]>",
        node_incremental = "<C-]>",
        node_decremental = "<C-[>",
      },
    },
  },
}
