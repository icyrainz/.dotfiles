return {
  "folke/trouble.nvim",
  keys = {
    { "<leader>xx", "<CMD>TroubleToggle<CR>", desc = "[trouble] toggle" },
    { "<leader>xw", "<CMD>Trouble workspace_diagnostics<CR>", desc = "[trouble] workspace diagnostics" },
    { "<leader>xd", "<CMD>Trouble document_diagnostics<CR>", desc = "[trouble] document diagnostics" },
    { "<leader>xl", "<CMD>Trouble loclist<CR>", desc = "[trouble] loclist" },
    { "<leader>xq", "<CMD>Trouble quickfix<CR>", desc = "[trouble] quickfix" },
    { "gR", "<CMD>Trouble lsp_references<CR>", desc = "[trouble] references" },
  },
}
