return {
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["gt"] = { name = "" },
        ["gT"] = { name = "" },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    init = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      -- disable a keymap
      keys[#keys + 1] = { "gy", false }
      keys[#keys + 1] = {
        "gl",
        function()
          vim.diagnostic.open_float()
        end,
        desc = "Diagnostics float",
      }
      keys[#keys + 1] = {
        "gt",
        function()
          require("telescope.builtin").lsp_type_definitions({ reuse_win = true })
        end,
        desc = "Goto Type Definition",
      }
    end,
    -- opts = {
    --   servers = {
    --     tsserver = {
    --       autostart = false,
    --     },
    --   },
    -- },
  },
}
