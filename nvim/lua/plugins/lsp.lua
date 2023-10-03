return {
  {
    "VonHeikemen/lsp-zero.nvim",
    event = "VeryLazy",
    branch = "v2.x",
    config = function()
      -- This is where you modify the settings for lsp-zero
      -- Note: autocompletion settings will not take effect

      require("lsp-zero.settings").preset({})
    end,
  },
  {
    "neovim/nvim-lspconfig",
    cmd = "LspInfo",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "williamboman/mason-lspconfig.nvim",
      "williamboman/mason.nvim",
      "VonHeikemen/lsp-zero.nvim",
    },
    config = function()
      -- This is where all the LSP shenanigans will live

      local lsp = require("lsp-zero")

      lsp.preset({
        name = "recommended",
        set_lsp_keymaps = {
          preserve_mappings = false,
          omit = {
            "gd",
            "gD",
            "gi",
            "go",
            "gr",
            "gs",
            "<F3>",

            "gl"
          },
        },
      })

      lsp.ensure_installed({
        "rust_analyzer",
        "tsserver",
        "lua_ls",
      })

      lsp.set_sign_icons({
        error = "✘",
        warn = "▲",
        hint = "⚑",
        info = "»",
      })

      require("lspconfig").lua_ls.setup(lsp.nvim_lua_ls())


      lsp.on_attach(function(_, bufnr)
        local function opts(desc)
          return { desc = "[LSP] " .. desc, buffer = bufnr, remap = false }
        end

        -- vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts(bufnr, "Hover"))
        vim.keymap.set("n", "<leader>sw", function() vim.lsp.buf.workspace_symbol() end, opts("Workspace symbol"))
        -- vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts("Open diagnostics float"))
        -- vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end, opts("Go to next diagnostic"))
        -- vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end, opts("Go to previous diagnostic"))
        -- vim.keymap.set("n", "<leader>wa", function()
        -- 	vim.lsp.buf.code_action()
        -- end, opts("Code action"))
        -- vim.keymap.set("n", "<leader>rr", function() vim.lsp.buf.references() end, opts("References"))
        -- vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts("Rename"))
        -- vim.keymap.set("n", "<leader>wf", function() vim.lsp.buf.format() end, opts("Format"))
        vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts("Definition"))
        vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts("Declaration"))
        vim.keymap.set("n", "ge", function() vim.lsp.buf.implementation() end, opts("Implementation"))
        vim.keymap.set("n", "gt", function() vim.lsp.buf.type_definition() end, opts("Type definition"))
        vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts("References"))
        vim.keymap.set("n", "<leader>k", function() vim.lsp.buf.signature_help() end, opts("Signature help"))
        vim.keymap.set("i", "<C-s>", function() vim.lsp.buf.signature_help() end, opts("Signature help"))

        vim.keymap.set("n", "gl", "<cmd>lua vim.diagnostic.open_float()<cr>", opts("Diagnostics float"))


        -- If null-ls exists, run format using null-ls. Otherwise use other LSP.
        vim.keymap.set({ "n", "x" }, "<F3>", function()
          local ft = vim.bo[bufnr].filetype
          local have_nls = package.loaded["null-ls"]
              and (#require("null-ls.sources").get_available(ft, "NULL_LS_FORMATTING") > 0)

          vim.lsp.buf.format({
            bufnr = bufnr,
            filter = function(client)
              if have_nls then
                return client.name == "null-ls"
              end
              return client.name ~= "null-ls"
            end
          })
        end, opts("Format buffer"))
      end)

      lsp.skip_server_setup({ "rust_analyzer", "tsserver", "elixirls" })

      -- Setup for ufo
      lsp.set_server_config({
        capabilities = {
          textDocument = {
            foldingRange = {
              dynamicRegistration = false,
              lineFoldingOnly = true,
            },
          },
        },
      })

      -- lsp.format_mapping("gq", {
      -- 	format_opts = {
      -- 		async = false,
      -- 		timeout_ms = 10000,
      -- 	},
      -- 	servers = {
      -- 		["null-ls"] = { "javascript", "typescript", "lua" },
      -- 	},
      -- })

      lsp.setup()
    end,
  },
}
