return {
  "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
  },
  config = function()
    require("lsp_lines").setup()
    vim.diagnostic.config({
      virtual_text = false,
      virtual_lines = { only_current_line = true },
    })
  end,
}
