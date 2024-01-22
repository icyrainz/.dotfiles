return {
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["cr"] = { name = "+coerce" },
      },
    },
  },
  {

    "gregorias/coerce.nvim",
    event = "BufEnter",
    config = true,
  },
}
