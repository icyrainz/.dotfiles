local lsp = require("lsp-zero")

lsp.preset("recommended")

lsp.ensure_installed({
  'rust_analyzer',
  'tsserver',
})

local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}
local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
  ['<CR>'] = cmp.mapping.confirm({ select = true }),
  ['<C-Space>'] = cmp.mapping.complete(),
})

lsp.setup_nvim_cmp({
  mapping = cmp_mappings
})


local function opts(desc)
  return { desc = 'lsp: ' .. desc, buffer = bufnr, remap = false }
end

lsp.on_attach(function(client, bufnr)
  -- vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts("Go to definition"))
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts("Hover"))
  vim.keymap.set("n", "<leader>ws", function() vim.lsp.buf.workspace_symbol() end, opts("Workspace symbol"))
  -- vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts("Open diagnostics float"))
  -- vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end, opts("Go to next diagnostic"))
  -- vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end, opts("Go to previous diagnostic"))
  vim.keymap.set("n", "<leader>wa", function() vim.lsp.buf.code_action() end, opts("Code action"))
  -- vim.keymap.set("n", "<leader>rr", function() vim.lsp.buf.references() end, opts("References"))
  -- vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts("Rename"))
  vim.keymap.set("i", "<C-j>", function() vim.lsp.buf.signature_help() end, opts("Signature help"))
end)

lsp.skip_server_setup({ 'rust_analyzer', 'tsserver' })

lsp.setup()
