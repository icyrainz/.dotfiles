vim.g.mapleader = " "

-- vim.keymap.set("n", "-", vim.cmd.Ex)

-- vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
-- vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- vim.keymap.set("x", "<leader>p", "\"_dP", { desc = "Paste without yanking" })
-- vim.keymap.set("x", "<leader>y", "\"+d", { desc = "Yank and delete" })
--
-- vim.keymap.set("n", "d", "\"_d")
-- vim.keymap.set("v", "d", "\"_d")

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines keeping cursor position" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Go down half page" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Go up half page" })
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "x", "\"_x", { desc = "Delete character without yanking" })

vim.keymap.set("i", "jj", "<Esc>", { desc = "Escape" })

vim.keymap.set("n", "<leader>A", "ggVG", { desc = "Select all" })
vim.keymap.set("n", "<leader>a", "ggVG\"+y", { desc = "Yank whole buffer" })

vim.keymap.set("n", "<leader>o", "i<CR><Esc>^", { desc = "Split line" })
vim.keymap.set("n", "<leader>j", "o<Esc>", { desc = "Goto new line below" })

vim.keymap.set("n", "c*", "*``cgn", { desc = "Replace word" })
vim.keymap.set("n", "c#", "#``cgN", { desc = "Replace word reverse" })

vim.keymap.set("i", "<C-h>", "<Left>", { desc = "Move cursor left" })
vim.keymap.set("i", "<C-l>", "<Right>", { desc = "Move cursor right" })
vim.keymap.set("i", "<C-k>", "<Esc>O", { desc = "Insert empty line above" })

-- vim.keymap.set("v", "<", "<gv", { desc = "Shift left" })
-- vim.keymap.set("v", ">", ">gv", { desc = "Shift right" })

vim.keymap.set("n", "<leader>bd", ":bd<CR>", { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>bD", ":bd!<CR>", { desc = "Delete buffer without saving" })

vim.keymap.set("n", "<A-Left>", ":vertical resize -5<CR>", { silent = true, desc = "Resize vertical -5" })
vim.keymap.set("n", "<A-Right>", ":vertical resize +5<CR>", { silent = true, desc = "Resize vertical +5" })
vim.keymap.set("n", "<A-Up>", ":resize +2<CR>", { silent = true, desc = "Resize +2" })
vim.keymap.set("n", "<A-Down>", ":resize -2<CR>", { silent = true, desc = "Resize -2" })

vim.keymap.set("n", "<leader>cp", "<CMD>call setreg('+', expand('%:p:~'))<CR>", { desc = "Copy current buffer file path to clipboard"})
vim.keymap.set("n", "<leader>cP", "<CMD>call setreg('+', expand('%:p:~:h'))<CR>", { desc = "Copy current buffer path to clipboard"})
vim.keymap.set("n", "<leader>cf", "<CMD>call setreg('+', expand('%:t'))<CR>", { desc = "Copy current buffer file name to clipboard"})

vim.keymap.set("i", "<C-a>", "<Esc>I", { silent = true, desc = "Goto start of line" })
vim.keymap.set("i", "<C-e>", "<Esc>A", { silent = true, desc = "Goto end of line" })

vim.keymap.set("n", "<leader>t2", "<CMD>lua vim.opt.shiftwidth = 2<CR>", { desc = "Change tab size to 2"})

