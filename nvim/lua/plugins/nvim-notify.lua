return {
  'rcarriga/nvim-notify',
  enabled = true,
  config = function()
    require("notify").setup({
      background_colour = "#000000",
    })
  end,
}
