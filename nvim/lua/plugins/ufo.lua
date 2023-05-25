return {
  "kevinhwang91/nvim-ufo",
  init = function()
    vim.o.foldcolumn = '1' -- '0' is not bad
    vim.o.foldlevel = 99   -- Using ufo provider need a large value, feel free to decrease the value
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true

    -- vim.keymap.set('n', 'zr', require('ufo').openAllFolds)
    -- vim.keymap.set('n', 'zm', require('ufo').closeAllFolds)
  end,
  config = true,
}
