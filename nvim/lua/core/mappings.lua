vim.g.mapleader = " "

-- vim.keymap.set("n", "-", vim.cmd.Ex)

-- vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
-- vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

vim.keymap.set("x", "<leader>p", "\"_dP", { desc = "Paste without yanking" })

-- vim.keymap.set("n", "<leader>d", "\"+d")
-- vim.keymap.set("v", "<leader>d", "\"+d")

vim.keymap.set("n", "<leader>a", "ggVG", { desc = "Select all" })

vim.keymap.set("n", "<leader>o", "i<CR><Esc>^", { desc = "Split line" })

vim.keymap.set("n", "c*", "*``cgn", { desc = "Replace word" })
vim.keymap.set("n", "c#", "#``cgN", { desc = "Replace word reverse" })

vim.keymap.set("i", "<C-h>", "<Left>", { desc = "Move cursor left" })
vim.keymap.set("i", "<C-l>", "<Right>", { desc = "Move cursor right" })
vim.keymap.set("i", "<C-k>", "<Esc>O", { desc = "Insert empty line above" })

-- vim.keymap.set("v", "<", "<gv", { desc = "Shift left" })
-- vim.keymap.set("v", ">", ">gv", { desc = "Shift right" })

vim.keymap.set("n", "<leader>bd", ":bd<CR>", { desc = "Delete buffer" })

vim.keymap.set("n", "<leader>q", ":cclose<CR>", { desc = "Close quickfix" })
