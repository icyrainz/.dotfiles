return {
  "neovim/nvim-lspconfig",
  init = function()
    local keys = require("lazyvim.plugins.lsp.keymaps").get()
    -- disable a keymap
    keys[#keys + 1] = { "gy", false }
    keys[#keys + 1] = {
      "<C-s>",
      mode = { "i" },
      function()
        vim.lsp.buf.signature_help()
      end,
      desc = "Signature Help",
    }

    keys[#keys + 1] = {
      "gl",
      function()
        vim.diagnostic.open_float()
      end,
      desc = "Diagnostics float",
    }
  end,

  opts = {
    servers = {
      tsserver = {
        keys = {
          {
            "<leader>cio",
            function()
              vim.lsp.buf.code_action({
                apply = true,
                context = {
                  only = { "source.organizeImports.ts" },
                  diagnostics = {},
                },
              })
            end,
            desc = "Organize Imports",
          },
          {
            "<leader>cir",
            function()
              vim.lsp.buf.code_action({
                apply = true,
                context = {
                  only = { "source.removeUnused.ts" },
                  diagnostics = {},
                },
              })
            end,
            desc = "Remove Unused Imports",
          },
        },
      },
    },
  },
}
