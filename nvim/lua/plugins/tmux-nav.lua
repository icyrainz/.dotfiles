return {
  "alexghergh/nvim-tmux-navigation",
  config = function()
    local nvim_tmux_nav = require("nvim-tmux-navigation")

    -- Disable warping 
    vim.g.tmux_navigator_no_wrap = 1

    nvim_tmux_nav.setup({})

    vim.keymap.set("n", "<C-h>", nvim_tmux_nav.NvimTmuxNavigateLeft)
    vim.keymap.set("n", "<C-j>", nvim_tmux_nav.NvimTmuxNavigateDown)
    vim.keymap.set("n", "<C-k>", nvim_tmux_nav.NvimTmuxNavigateUp)
    vim.keymap.set("n", "<C-l>", nvim_tmux_nav.NvimTmuxNavigateRight)
    vim.keymap.set("n", "<C-\\>", nvim_tmux_nav.NvimTmuxNavigateLastActive)
  end,
}
