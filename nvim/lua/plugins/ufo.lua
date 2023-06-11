return {
  "kevinhwang91/nvim-ufo",
  event = "VeryLazy",
  keys = {
    { "zR", function() require('ufo').openAllFolds() end, desc = "Open all folds"},
    { "zM", function() require('ufo').closeAllFolds() end, desc = "Close all folds"},
  },
  init = function()
    vim.o.foldcolumn = '1' -- '0' is not bad
    vim.o.foldlevel = 99   -- Using ufo provider need a large value, feel free to decrease the value
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true
  end,
  config = true,
}
