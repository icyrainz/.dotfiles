return {
  "folke/edgy.nvim",
  opts = {
    animate = {
      enabled = false,
    },
    options = {
      right = { size = 50 },
    },
    left = {
      {
        title = "Neo-Tree",
        ft = "neo-tree",
        filter = function(buf)
          return vim.b[buf].neo_tree_source == "filesystem"
        end,
        pinned = true,
      },
    },
  },
}
