return {
  {
    "jackMort/ChatGPT.nvim",
    enabled = os.getenv("USE_AI_TOOLS") == "true",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd = { "ChatGPT" },
    opts = {
      popup_input = {
        submit = "<Enter>",
        submit_n = "<A-Enter>",
      }
    },
    keys = {
      {
        "<leader>no",
        "<CMD>ChatGPT<CR>",
        desc = "ChatGPT",
      },
      {
        "<leader>ne",
        "<CMD>ChatGPTEditWithInstructions<CR>",
        mode = "v",
        desc = "ChatGPT Edit (selected)",
      },
      {
        "<leader>ne",
        "<CMD>ChatGPTEditWithInstructions<CR>",
        desc = "ChatGPT Edit (all)",
      },
    }
  },
}
