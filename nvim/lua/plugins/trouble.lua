return {
  "folke/trouble.nvim",
  enabled = false,
  config = function()
    local function opts(desc)
      return { desc = 'trouble: ' .. desc, silent = true, noremap = true }
    end

    vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<cr>", opts("toggle"))
    vim.keymap.set("n", "<leader>xw", "<cmd>Trouble workspace_diagnostics<cr>", opts("workspace diagnostics"))
    vim.keymap.set("n", "<leader>xd", "<cmd>Trouble document_diagnostics<cr>", opts("document diagnostics"))
    vim.keymap.set("n", "<leader>xl", "<cmd>Trouble loclist<cr>", opts("loclist"))
    vim.keymap.set("n", "<leader>xq", "<cmd>Trouble quickfix<cr>", opts("quickfix"))
    vim.keymap.set("n", "gR", "<cmd>Trouble lsp_references<cr>", opts("references"))
  end,
}
