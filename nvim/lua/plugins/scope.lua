return {
  "tiagovla/scope.nvim",
  config = function()
    require('scope').setup()
    require("telescope").load_extension("scope")
  end,
}
