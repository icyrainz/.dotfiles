require("telescope").load_extension("projects")

vim.keymap.set("n", "<leader>fp", ":Telescope projects<CR>", { noremap = true, silent = true, desc = "Find project" })
