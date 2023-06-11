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
        "<leader>co",
        "<CMD>ChatGPT<CR>",
        desc = "ChatGPT",
      },
      {
        "<leader>ce",
        "<CMD>ChatGPTEditWithInstructions<CR>",
        mode = "v",
        desc = "ChatGPT Edit (selected)",
      },
      {
        "<leader>ce",
        "<CMD>ChatGPTEditWithInstructions<CR>",
        desc = "ChatGPT Edit (all)",
      },
      {
        "<leader>cr",
        "<CMD>ChatGPTRun<CR>",
        desc = "ChatGPT Run",
      },
    }
  },
}
