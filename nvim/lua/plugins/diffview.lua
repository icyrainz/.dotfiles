return {
  "sindrets/diffview.nvim",
  config = function()
    require('diffview').setup()

    vim.keymap.set("n", "<leader>gdo", "<cmd>DiffviewOpen<CR>", { desc = "Diffview Open" })
    vim.keymap.set("n", "<leader>gdc", "<cmd>DiffviewClose<CR>", { desc = "Diffview Close" })
  end,
}
