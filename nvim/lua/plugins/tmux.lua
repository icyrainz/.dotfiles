return {
  "aserowy/tmux.nvim",
  config = function()
    require("tmux").setup({
      navigation = {
        cycle_navigation = false,
        enable_default_keybindings = true,
      },
      resize = {
        resize_step_x = 5,
        resize_step_y = 5,
      }
    })

    vim.cmd([[nnoremap <silent> <A-h> <cmd>lua require("tmux").resize_left()<CR>]])
    vim.cmd([[nnoremap <silent> <A-j> <cmd>lua require("tmux").resize_bottom()<CR>]])
    vim.cmd([[nnoremap <silent> <A-k> <cmd>lua require("tmux").resize_top()<CR>]])
    vim.cmd([[nnoremap <silent> <A-l> <cmd>lua require("tmux").resize_right()<CR>]])
  end
}
