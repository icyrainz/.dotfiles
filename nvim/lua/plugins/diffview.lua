local wk = require("which-key")
wk.register({
  ["<leader>"] = {
    g = {
      d = { name = "+diffview" },
    },
  },
})

return {
  "sindrets/diffview.nvim",
  keys = {
    { "<leader>gdo", "<CMD>DiffviewOpen<CR>", desc = "Diffview open" },
    { "<leader>gdc", "<CMD>DiffviewClose<CR>", desc = "Diffview close" },
    { "<leader>gdb", "<CMD>DiffviewFileHistory<CR>", desc = "Diffview file history (branch)" },
    { "<leader>gdf", "<CMD>DiffviewFileHistory %<CR>", desc = "Diffview file history (current buffer)" },
  },
  config = true,
}
