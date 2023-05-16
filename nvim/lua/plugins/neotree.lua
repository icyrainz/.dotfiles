return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v2.x",
  config = function()
    require("neo-tree").setup({
      close_if_last_window = true,
      filesystem = {
        follow_current_file = true,
      },
    })
    vim.keymap.set("n", "<leader>e", ":Neotree toggle<cr>", { desc = "Neotree toggle" })
    vim.keymap.set("n", "<leader>er", ":Neotree toggle<cr>", { desc = "Neotree toggle" })
    vim.keymap.set("n", "<leader>ef", ":Neotree float toggle<cr>", { desc = "Neotree toggle float" })
  end,
}
