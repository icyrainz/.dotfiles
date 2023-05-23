return {
  {
    "jackMort/ChatGPT.nvim",
    enabled = os.getenv("USE_AI_TOOLS") == "true",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      popup_input = {
        submit = "<Enter>",
        submit_n = "<A-Enter>",
      }
    },
    init = function()
      vim.keymap.set("n", "<leader>no", "<cmd>ChatGPT<CR>", {
        desc = "ChatGPT",
      })
      vim.keymap.set("n", "<leader>ne", "<cmd>ChatGPTEditWithInstructions<CR>", {
        desc = "ChatGPT Edit (all)",
      })
      vim.keymap.set("v", "<leader>ne", function()
        require("chatgpt").edit_with_instructions()
      end, {
        desc = "ChatGPT Edit (selected)",
        silent = true,
      })
    end,
  },
}
