require("toggleterm").setup()

vim.keymap.set('n', "<leader>tt", ":ToggleTerm<CR>", { desc = "Toggle terminal" })
