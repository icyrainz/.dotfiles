local wk = require("which-key")
wk.add({
  { "<leader>gt", group = "toggle" },
})

return {
  {
    "lewis6991/gitsigns.nvim",
    enabled = true,
    opts = {
      current_line_blame_opts = {
        delay = 0,
      },
    },
    keys = {
      {
        "<leader>gtl",
        function()
          require("gitsigns").toggle_current_line_blame()
        end,
        desc = "Toggle blame line",
      },
    },
  },
}
