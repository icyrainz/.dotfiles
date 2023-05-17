return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup()

    vim.keymap.set('n', "<leader>Tv", ":ToggleTerm size=80 direction=vertical<CR>",
      { desc = "Toggle terminal vertical" })
    vim.keymap.set('n', "<leader>Th", ":ToggleTerm direction=horizontal<CR>", { desc = "Toggle terminal horizontal" })
  end,
}
