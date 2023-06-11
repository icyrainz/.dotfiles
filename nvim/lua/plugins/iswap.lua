return {
  "mizlan/iswap.nvim",
  keys = {
    { "<leader>[", ":ISwapNodeWithLeft<CR>", desc = "Swap left" },
    { "<leader>]", ":ISwapNodeWithRight<CR>", desc = "Swap right" },
  },
  opts = {
    move_cursor = true,
    flash_style = false,
    autoswap = true,
  },
}
