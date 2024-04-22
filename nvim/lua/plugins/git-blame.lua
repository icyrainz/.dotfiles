return {
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["<leader>gu"] = { name = "+url" },
      },
    },
  },
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
