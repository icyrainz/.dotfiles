local wk = require("which-key")
wk.add({
  { "<leader>gu", group = "url" },
})

return {
  {
    "f-person/git-blame.nvim",
    keys = {
      { "<leader>guf", "<CMD>GitBlameCopyFileURL<CR>", desc = "Git blame copy file URL" },
      { "<leader>guc", "<CMD>GitBlameCopyCommitURL<CR>", desc = "Git blame copy commit URL" },
    },
    init = function()
      vim.g.gitblame_display_virtual_text = 0
      vim.g.gitblame_date_format = "%x %X"
    end,
  },
}
