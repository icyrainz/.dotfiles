local lsp = require("lsp-zero")

lsp.preset({
  name = 'recommended',
  set_lsp_keymaps = {
    preserve_mappings = true,
    omit = { 'go' },
  },
})

lsp.ensure_installed({
  'rust_analyzer',
  'tsserver',
  'eslint',
  'lua_ls',
})

lsp.set_sign_icons({
  error = "✘",
  warn = "▲",
  hint = "⚑",
  info = "»",
})

require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())
require('lspconfig').eslint.setup({})
require('lspconfig').tsserver.setup({})

lsp.on_attach(function(client, bufnr)
  local function opts(desc)
    return { desc = 'lsp: ' .. desc, buffer = bufnr, remap = false }
  end

  -- vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts(bufnr, "Hover"))
  vim.keymap.set("n", "<leader>ws", function() vim.lsp.buf.workspace_symbol() end, opts("Workspace symbol"))
  -- vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts("Open diagnostics float"))
  -- vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end, opts("Go to next diagnostic"))
  -- vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end, opts("Go to previous diagnostic"))
  vim.keymap.set("n", "<leader>wa", function() vim.lsp.buf.code_action() end, opts("Code action"))
  -- vim.keymap.set("n", "<leader>rr", function() vim.lsp.buf.references() end, opts("References"))
  -- vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts("Rename"))
  -- vim.keymap.set("n", "<leader>wf", function() vim.lsp.buf.format() end, opts("Format"))
  vim.keymap.set("i", "<C-j>", function() vim.lsp.buf.signature_help() end, opts("Signature help"))
end)

lsp.skip_server_setup({ 'rust_analyzer', 'tsserver' })

lsp.setup()

local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

require('luasnip.loaders.from_vscode').lazy_load()

cmp.setup({
  sources = {
    { name = 'copilot' },
    { name = 'nvim_lsp' },
    { name = 'path' },
    { name = 'luasnip', keuword_length = 2 },
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  formatting = {
    fields = { "menu", "abbr", "kind" },

    format = function(entry, item)
      local menu_icon = {
        copilot = "",
        nvim_lsp = "λ",
        luasnip = "⋗",
        path = "🖫",
        nvim_lua = "Π",
      }

      item.menu = menu_icon[entry.source.name]
      return item
    end,
  },
  mapping = {
    ['<C-f>'] = cmp_action.luasnip_jump_forward(),
    ['<C-b>'] = cmp_action.luasnip_jump_backward(),
    ["<Tab>"] = cmp_action.luasnip_supertab(),
    ["<S-Tab>"] = cmp_action.luasnip_shift_supertab(),
    ['<C-BS>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = false
    }),
  }
})

require('mason-tool-installer').setup({
  ensure_installed = { "codelldb", "prettier", "prettierd" },
  auto_update = true,
  run_on_start = true,
})

-- Setup null-ls
local null_ls = require("null-ls")

null_ls.setup({
  sources = {
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.diagnostics.eslint,
  },
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.keymap.set("n", "<leader>fm", function()
        vim.lsp.buf.format({ bufnr = vim.api.nvim_get_current_buf() })
      end, { buffer = bufnr, desc = "[LSP] Format" })
    end
  end,
})


-- Setup typescript
require('typescript').setup({
  server = {
    on_attach = function(client, bufnr)
      vim.keymap.set('n', '<leader>ci', '<cmd>TypescriptAddMissingImports<CR>', { buffer = bufnr })
    end
  }
})
