return {
  's1n7ax/nvim-window-picker',
  event = "VeryLazy",
  config = function()
    local picker = require('window-picker')
    picker.setup()

    vim.keymap.set("n", "<leader>ww", function()
      local picked_window_id = picker.pick_window() or vim.api.nvim_get_current_win()
      vim.api.nvim_set_current_win(picked_window_id)
    end, { desc = 'Pick a window' })
  end,
}
