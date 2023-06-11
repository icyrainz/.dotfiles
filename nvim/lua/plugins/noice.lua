return {
  {
    "folke/noice.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>nl", "<CMD>NoiceLast<CR>", desc = "[noice] last" },
      { "<leader>ne", "<CMD>NoiceErrors<CR>", desc = "[noice] errors" },
    },
    opts = {
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
        hover = {
          enabled = false,
        },
        signature = {
          enabled = false,
        },
      },
      presets = {
        bottom_search = true,
        long_message_to_split = false,
        lsp_doc_border = true,
      },
      cmdline = {
        view = "cmdline",
      },
    },
  },
}
