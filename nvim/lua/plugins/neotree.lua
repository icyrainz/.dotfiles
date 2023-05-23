return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v2.x",
  opts = {
    -- close_if_last_window = true,
    filesystem = {
      follow_current_file = true,
    },
    window = {
      mappings = {
        ["<BS>"] = function(state)
          local node = state.tree:get_node()
          require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
        end
      }
    }
  },
  init = function()
    vim.keymap.set("n", "<leader>e", ":Neotree toggle left<cr>", { desc = "Neotree toggle left" })
    vim.keymap.set("n", "<leader>E", ":Neotree toggle float<cr>", { desc = "Neotree toggle float" })
  end,
}
