-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

if vim.g.neovide then
  vim.o.guifont = "Iosevka Nerd Font:h20"
  vim.g.neovide_window_blurred = true
  vim.keymap.set({ "n", "v", "i" }, "<D-c>", '"+y')
  vim.keymap.set({ "n", "v", "i" }, "<D-v>", '"+p')
end
