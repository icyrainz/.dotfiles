return {
  "folke/trouble.nvim",
  keys = {
    { "<leader>xx", "<cmd>TroubleToggle<CR>", desc = "[trouble] toggle" },
    { "<leader>xw", "<cmd>Trouble workspace_diagnostics<CR>", desc = "[trouble] workspace diagnostics" },
    { "<leader>xd", "<cmd>Trouble document_diagnostics<CR>", desc = "[trouble] document diagnostics" },
    { "<leader>xl", "<cmd>Trouble loclist<CR>", desc = "[trouble] loclist" },
    { "<leader>xq", "<cmd>Trouble quickfix<CR>", desc = "[trouble] quickfix" },
    { "gR", "<cmd>Trouble lsp_references<CR>", desc = "[trouble] references" },
  },
}
