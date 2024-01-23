return {
  {
    "hedyhli/outline.nvim",
    keys = {
      { "<leader>co", "<CMD>Outline<CR>", desc = "Symbols outline" },
    },
    opts = {},
  },
  {
    "folke/edgy.nvim",
    opts = function(_, opts)
      opts.right = opts.right or {}
      table.insert(opts.right, {
        title = "Symbols Outline",
        ft = "Outline",
        pinned = true,
        open = "Outline",
      })
    end,
  },
}
