return {
  "mizlan/iswap.nvim",
  init = function()
    vim.keymap.set("n", "<leader>[", ":ISwapWithLeft<CR>", { desc = "Swap left", silent = true })
    vim.keymap.set("n", "<leader>]", ":ISwapWithRight<CR>", { silent = true, desc = "Swap right" })
  end,
  opts = {
    move_cursor = true,
    flash_style = false,
    autoswap = true,
  },
}
