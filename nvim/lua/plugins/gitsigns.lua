return {
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["<leader>gh"] = { name = "+hunks" },
      },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame_opts = {
        delay = 0,
      },
    },
    keys = {
      {
        "<leader>gbl",
        function()
          require("gitsigns").toggle_current_line_blame()
        end,
        desc = "Toggle blame line",
      },
    },
  },
}
