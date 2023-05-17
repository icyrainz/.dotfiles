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
    vim.keymap.set("n", "<leader>e", ":Neotree toggle left<cr>", { desc = "Neotree toggle left" })
    vim.keymap.set("n", "<leader>E", ":Neotree toggle float<cr>", { desc = "Neotree toggle float" })
  end,
}
