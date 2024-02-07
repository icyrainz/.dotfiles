return {
  {
    "hedyhli/outline.nvim",
    cmd = { "Outline" },
    keys = {
      { "<leader>co", "<CMD>Outline<CR>", desc = "Symbols outline" },
    },
    opts = {
      keymaps = {
        up_and_jump = "<C-p>",
        down_and_jump = "<C-n>",
      },
    },
  },
  {
    "folke/edgy.nvim",
    opts = function(_, opts)
      opts.right = opts.right or {}
      table.insert(opts.right, {
        title = "Symbols Outline",
        ft = "Outline",
        open = "Outline",
      })
    end,
  },
}
