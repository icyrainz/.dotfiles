vim.g.mapleader = " "

-- vim.keymap.set("n", "-", vim.cmd.Ex)

-- vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
-- vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- vim.keymap.set("x", "<leader>p", "\"_dP", { desc = "Paste without yanking" })
-- vim.keymap.set("x", "<leader>y", "\"+d", { desc = "Yank and delete" })
--
-- vim.keymap.set("n", "d", "\"_d")
-- vim.keymap.set("v", "d", "\"_d")

vim.keymap.set("i", "jj", "<Esc>", { desc = "Escape" })
vim.keymap.set("n", "q:", ":q")

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

vim.keymap.set("n", "<Left>", ":vertical resize -5<CR>", { silent = true, desc = "Resize vertical -5" })
vim.keymap.set("n", "<Right>", ":vertical resize +5<CR>", { silent = true, desc = "Resize vertical +5" })
vim.keymap.set("n", "<Up>", ":resize +2<CR>", { silent = true, desc = "Resize +2" })
vim.keymap.set("n", "<Down>", ":resize -2<CR>", { silent = true, desc = "Resize -2" })

vim.keymap.set("n", "<leader>cp", "<cmd>call setreg('+', expand('%:p:~'))<CR>", { desc = "Copy current buffer file path to clipboard"})
vim.keymap.set("n", "<leader>cP", "<cmd>call setreg('+', expand('%:p:~:h'))<CR>", { desc = "Copy current buffer path to clipboard"})

-- vim.keymap.set("n", "<leader>,", "g_a, <Esc>D", { desc = "Insert comma to end of the line"})
