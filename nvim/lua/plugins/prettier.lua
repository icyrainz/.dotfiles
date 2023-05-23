return {
  "MunifTanjim/prettier.nvim",
  opts = {
    bin = "prettierd",
    filetypes = {
      "css",
      "graphql",
      "html",
      "javascript",
      "javascriptreact",
      "json",
      "less",
      "markdown",
      "scss",
      "typescript",
      "typescriptreact",
      "yaml",
      "lua",
    },
  },
  init = function()
    vim.keymap.set("n", "<leader>pf", ":Prettier<CR>", { desc = "Prettier format" })
  end,
}
