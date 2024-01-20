local wk = require("which-key")
wk.register({
  ["<leader>"] = {
    g = {
      b = { name = "+blame" },
    },
  },
})

return {
  "f-person/git-blame.nvim",
  keys = {
    { "<leader>gbf", "<CMD>GitBlameCopyFileURL<CR>", desc = "Git blame copy file URL" },
    { "<leader>gbc", "<CMD>GitBlameCopyCommitURL<CR>", desc = "Git blame copy commit URL" },
  },
  init = function()
    vim.g.gitblame_display_virtual_text = 0
    vim.g.gitblame_date_format = "%x %X"
  end,
}
