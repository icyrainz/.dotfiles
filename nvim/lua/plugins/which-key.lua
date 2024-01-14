local wk = require("which-key")
wk.register({
  ["<leader>"] = {
    o = { name = "+open" },
    i = { name = "+insert" },
  },
})

return {
  "folke/which-key.nvim",
  opts = {
    key_labels = {
      ["<space>"] = "SPC",
      ["<cr>"] = "RET",
      ["<tab>"] = "TAB",
    },
  },
}
