return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v2.x",
  config = function()
    vim.keymap.set("n", "<leader>ft", ":Neotree toggle<cr>")
  end,
}
