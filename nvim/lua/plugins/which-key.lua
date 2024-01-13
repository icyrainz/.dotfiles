local wk = require("which-key")
wk.register({
  cr = {
    name = "+coercion",
    s = { desc = "Snake Case" },
    _ = { desc = "Snake Case" },
    m = { desc = "Mixed Case" },
    c = { desc = "Camel Case" },
    u = { desc = "Snake Upper Case" },
    U = { desc = "Snake Upper Case" },
    k = { desc = "Kebab Case" },
    t = { desc = "Title Case (not reversible)" },
    ["-"] = { desc = "Kebab Case (not reversible)" },
    ["."] = { desc = "Dot Case (not reversible)" },
    ["<space>"] = { desc = "Space Case (not reversible)" },
  },
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
