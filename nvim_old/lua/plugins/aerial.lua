return {
  'stevearc/aerial.nvim',
  opts = {
    on_attach = function(bufnr)
      -- Jump forwards/backwards with '{' and '}'
      vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
      vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
    end,
  },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  keys = {
    { "<leader>sa", "<cmd>AerialToggle!<CR>", desc = "Aerial" }
  }
}
