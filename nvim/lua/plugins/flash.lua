return {
  "folke/flash.nvim",
  opts = {
    modes = {
      search = {
        enabled = false,
      },
    },
  },
  keys = {
    -- Remote flash
    { "r", mode = { "o" }, false },
  },
}
