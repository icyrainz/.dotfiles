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
    vim.keymap.set("n", "<leader>ft", ":Neotree toggle<cr>")
  end,
}
