return {
  "chrisgrieser/nvim-spider",
  opts = { skipInsignificantPunctuation = true },
  keys = {
    {
      "e",
      "<CMD>lua require('spider').motion('e')<CR>",
      mode = { "n", "o", "x" },
      desc = "󱇫 e",
    },
    {
      "b",
      "<CMD>lua require('spider').motion('b')<CR>",
      mode = { "n", "o", "x" },
      desc = "󱇫 b",
    },
  },
}
