return {
  "mizlan/iswap.nvim",
  init = function()
    vim.keymap.set("n", "<leader>[", ":ISwapNodeWithLeft<CR>", { desc = "Swap left", silent = true })
    vim.keymap.set("n", "<leader>]", ":ISwapNodeWithRight<CR>", { silent = true, desc = "Swap right" })
  end,
  opts = {
    move_cursor = true,
    flash_style = false,
    autoswap = true,
  },
}
