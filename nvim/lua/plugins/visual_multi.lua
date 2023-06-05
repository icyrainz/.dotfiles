return {
  enabled = false,
  "mg979/vim-visual-multi",
  config = function()
    vim.g.VM_maps = {
      ["Add Cursor Down"] = "<A-n>",
      ["Add Cursor Up"] = "<A-p>",
    }
  end,
}
