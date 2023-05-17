return {
  "folke/neodev.nvim",
  dependencies = {
    "neovim/nvim-lspconfig"
  },
  config = function()
    require("neodev").setup({
      library = { plugins = { "nvim-dap.ui" }, types = true },
    })
  end
}
