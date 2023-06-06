return {
  "aserowy/tmux.nvim",
  config = function()
    require("tmux").setup({
      copy_sync = {
        enable = false,
      },
      navigation = {
        cycle_navigation = false,
        enable_default_keybindings = true,
      },
      resize = {
        resize_step_x = 5,
        resize_step_y = 2,
      }
    })

    vim.keymap.set({"n", "x"}, "<A-h>", "<cmd>lua require('tmux').resize_left()<CR>", { silent = true, desc = "Resize left" })
    vim.keymap.set({"n", "x"}, "<A-j>", "<cmd>lua require('tmux').resize_bottom()<CR>", { silent = true, desc = "Resize down" })
    vim.keymap.set({"n", "x"}, "<A-k>", "<cmd>lua require('tmux').resize_top()<CR>", { silent = true, desc = "Resize up" })
    vim.keymap.set({"n", "x"}, "<A-l>", "<cmd>lua require('tmux').resize_right()<CR>", { silent = true, desc = "Resize right" })

  end
}
