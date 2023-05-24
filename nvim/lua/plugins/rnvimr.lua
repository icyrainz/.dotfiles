return {
  'kevinhwang91/rnvimr',
  init = function ()
    vim.keymap.set("n", "<A-o>", ":RnvimrToggle<CR>", { desc = "Toggle Ranger" })
    vim.keymap.set("t", "<A-o>", "<C-\\><C-n>:RnvimrToggle<CR>", { desc = "Toggle Ranger" })
    vim.keymap.set("t", "<A-i>", "<C-\\><C-n>:RnvimrResize<CR>", { desc = "Toggle Ranger" })
  end
}
