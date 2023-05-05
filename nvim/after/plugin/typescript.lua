require('typescript').setup({
  server = {
    on_attach = function(client, bufnr)
      vim.keymap.set('n', '<leader>ci', '<cmd>TypescriptAddMissingImports<CR>', { buffer = bufnr })
    end
  }
})
