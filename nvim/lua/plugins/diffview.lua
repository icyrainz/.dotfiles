return {
  "sindrets/diffview.nvim",
  init = function()
    vim.keymap.set("n", "<leader>gdo", "<cmd>DiffviewOpen<CR>", { desc = "Diffview open" })
    vim.keymap.set("n", "<leader>gdc", "<cmd>DiffviewClose<CR>", { desc = "Diffview close" })
  end,
  config = true,
}
