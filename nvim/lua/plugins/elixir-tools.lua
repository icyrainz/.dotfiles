return {
  "elixir-tools/elixir-tools.nvim",
  version = "*",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local elixir = require("elixir")
    local elixirls = require("elixir.elixirls")

    elixir.setup {
      nextls = {
        enable = false,
        cmd = "/Users/tuephan/.local/share/nvim/mason/bin/nextls",
      },
      credo = {},
      elixirls = {
        enable = true,
        cmd = "/Users/tuephan/.local/share/nvim/mason/bin/elixir-ls",
        settings = elixirls.settings {
          enableTestLenses = true,
        },
      }
    }
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
}
