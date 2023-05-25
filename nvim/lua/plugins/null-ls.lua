return {
  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-lua/plenary.nvim",
    },
    config = function()
      local null_ls = require("null-ls")

      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.prettierd,
          -- null_ls.builtins.formatting.jq,
          -- null_ls.builtins.diagnostics.eslint,
          -- null_ls.builtins.formatting.stylua,
          --      null_ls.builtins.completion.spell,
          require("typescript.extensions.null-ls.code-actions"),
        },
      })
    end,
  },
  {
    "jay-babu/mason-null-ls.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
    opts = {
      ensure_installed = { "stylua", "jq", "prettierd" },
      automatic_setup = true,
      automatic_installation = true,
    },
  },
}
