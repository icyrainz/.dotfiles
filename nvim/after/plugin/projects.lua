require('telescope').load_extension('projects')

local project_nvim = require("project_nvim")
vim.keymap.set('n', '<leader>fp', ":Telescope projects<CR>", {noremap = true, silent = true, desc = "Find project"})
