return {
  "folke/flash.nvim",
  enabled = false,
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
