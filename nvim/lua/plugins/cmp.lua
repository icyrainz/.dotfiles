return {
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-buffer",
  -- "hrsh7th/cmp-cmdline",
  "saadparwaiz1/cmp_luasnip",
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "VonHeikemen/lsp-zero.nvim",
    },
    config = function()
      require("lsp-zero").extend_cmp()

      local cmp = require("cmp")
      local cmp_action = require("lsp-zero").cmp_action()

      cmp.setup({
        sources = {
          { name = "copilot" },
          { name = "codeium" },
          { name = "nvim_lsp" },
          { name = "luasnip", keyword_length = 2 },
          { name = "path" },
          { name = "buffer", keyword_length = 5 },
        },
        window = {
          documentation = cmp.config.window.bordered(),
        },
        formatting = {
          format = require('lspkind').cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            ellipsis_char = '',
            symbol_map = {
              Codeium = "",
              Copilot = "",
            },
          })
        },
        mapping = {
          ["<Tab>"] = cmp_action.luasnip_supertab(),
          ["<S-Tab>"] = cmp_action.luasnip_shift_supertab(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
        },
      })

      -- cmp.setup.cmdline("/", {
      --   mapping = cmp.mapping.preset.cmdline(),
      --   sources = {
      --     { name = "buffer" },
      --   },
      -- })
      --
      -- cmp.setup.cmdline(":", {
      --   completion = {
      --     autocomplete = false,
      --   },
      --   sources = cmp.config.sources({
      --     { name = "path" },
      --   }, {
      --     {
      --       name = "cmdline",
      --       option = {
      --         ignore_cmds = { "Man", "!" },
      --       },
      --     },
      --   }),
      -- })
    end,
  },
}
