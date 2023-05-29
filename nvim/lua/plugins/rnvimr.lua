return {
  'kevinhwang91/rnvimr',
  init = function ()
    vim.keymap.set("n", "<A-o>", ":RnvimrToggle<CR>", { desc = "Ranger toggle", silent = true })
    vim.keymap.set("t", "<A-o>", "<C-\\><C-n>:RnvimrToggle<CR>", { desc = "Ranger toggle", silent = true })
    vim.keymap.set("t", "<A-i>", "<C-\\><C-n>:RnvimrResize<CR>", { desc = "Ranger resize", silent = true })
  end
}
