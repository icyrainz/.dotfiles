return {
  "folke/flash.nvim",
  enabled = true,
  event = "VeryLazy",
  ---@type Flash.Config
  opts = {},
  keys = {
    {
      "<BS>",
      function()
        require("flash").treesitter({
          actions = {
            ["<BS>"] = "next",
          },
        })
      end,
      mode = { "n", "x", "o" },
      desc = "Incremental expand",
    },
  },
}
