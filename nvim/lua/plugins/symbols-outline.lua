return {
  "simrat39/symbols-outline.nvim",
  opts = {
    auto_preview = true,
    preview_bg_highlight = 'NormalFloat',
    autofold_depth = 1,
    keymaps = {
      focus_location = "o",
      hover_symbol = "K",
      toggle_preview = "P",
      rename_symbol = "r",
      code_actions = "a",
      fold = "h",
      unfold = "l",
      fold_all = "H",
      unfold_all = "L",
      fold_reset = "R",
    },
  },
  keys = {
    { "<leader>so", "<CMD>SymbolsOutline<CR>", desc = "Symbols outline" }
  },
}
