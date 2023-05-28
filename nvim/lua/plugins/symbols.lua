return {
  "simrat39/symbols-outline.nvim",
  config = true,
  init = function()
    vim.keymap.set('n', '<leader>sO', '<cmd>:SymbolsOutline<CR>')
  end,
}
