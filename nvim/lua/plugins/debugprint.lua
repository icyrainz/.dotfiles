return {
  {
    "andrewferrier/debugprint.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    event = "VeryLazy",
    version = "*",
    config = function()
      require('debugprint').setup({
        filetypes = {
          ["typescript"] = {
            left = 'log.info(`',
            right = '`);',
            mid_var = '${JSON.stringify(',
            right_var = ')}`);',
          }
        },
      })
    end,
  },
}
