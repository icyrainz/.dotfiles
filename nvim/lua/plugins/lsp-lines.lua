return {
  "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
  },
  config = function()
    require("lsp_lines").setup()
    vim.diagnostic.config({ virtual_text = false })

    vim.cmd([[autocmd! CursorHold * lua vim.diagnostic.config({ virtual_lines = { only_current_line = true } })]])
  end,
}
