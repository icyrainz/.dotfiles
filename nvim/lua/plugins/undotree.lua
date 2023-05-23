return {
  "mbbill/undotree",
  init = function()
    vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Toggle undotree" })
  end,
}
