require("toggleterm").setup()

vim.keymap.set('n', "<leader>etv", ":ToggleTerm size=80 direction=vertical<CR>", { desc = "Toggle terminal vertical" })
vim.keymap.set('n', "<leader>eth", ":ToggleTerm direction=horizontal<CR>", { desc = "Toggle terminal horizontal" })
