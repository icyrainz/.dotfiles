require("toggleterm").setup()

vim.keymap.set('n', "<leader>et", ":ToggleTerm<CR>", { desc = "Toggle terminal" })
