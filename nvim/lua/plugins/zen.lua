return {
  "folke/zen-mode.nvim",
  init = function()
    vim.keymap.set("n", "<leader>z", ":ZenMode<CR>", { silent = true })
  end,
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  }
}
