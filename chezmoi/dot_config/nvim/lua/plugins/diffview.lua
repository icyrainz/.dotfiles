local wk = require("which-key")
wk.add({
  { "<leader>od", group = "diffview" },
})

return {
  {
    "sindrets/diffview.nvim",
    keys = {
      { "<leader>odo", "<CMD>DiffviewOpen<CR>", desc = "Diffview open" },
      { "<leader>odc", "<CMD>DiffviewClose<CR>", desc = "Diffview close" },
      { "<leader>odb", "<CMD>DiffviewFileHistory<CR>", desc = "Diffview file history (branch)" },
      { "<leader>odf", "<CMD>DiffviewFileHistory %<CR>", desc = "Diffview file history (current buffer)" },
    },
    config = true,
  },
}
