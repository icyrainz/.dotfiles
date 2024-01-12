return {
  -- enabled = false,
  "numToStr/Navigator.nvim",
  keys = {
    { '<C-h>', '<CMD>NavigatorLeft<CR>', mode = { 'n', 't' }, desc = 'NavigatorLeft' },
    { '<C-l>', '<CMD>NavigatorRight<CR>', mode = { 'n', 't' }, desc = 'NavigatorRight' },
    { '<C-k>', '<CMD>NavigatorUp<CR>', mode = { 'n', 't' }, desc = 'NavigatorUp' },
    { '<C-j>', '<CMD>NavigatorDown<CR>', mode = { 'n', 't' }, desc = 'NavigatorDown' },
  },
  opts = {},
}
