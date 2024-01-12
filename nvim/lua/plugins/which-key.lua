local wk = require("which-key")
wk.register({
  ["<leader>"] = {
    [","] = { desc = "Toggle ',' EOL" },
    [";"] = { desc = "Toggle ';' EOL" },
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
