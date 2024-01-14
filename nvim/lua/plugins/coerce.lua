local wk = require("which-key")
wk.register({
  c = {
    r = { name = "+coerce" },
  },
})

return {
  "gregorias/coerce.nvim",
  event = "LazyFile",
  config = true,
}
