-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>A", function()
  vim.cmd("normal! gg")
  vim.cmd("normal! VG")
end, { silent = true, desc = "Select all" })

vim.keymap.set("n", "<leader>a", function()
  vim.cmd("normal! gg")
  vim.cmd("normal! VG")
  vim.cmd('normal! "+y')
end, { silent = true, desc = "Yank whole buffer" })

-- vim.keymap.set("n", "c*", "*``cgn", { silent = true, desc = "Replace word" })
-- vim.keymap.set("n", "c#", "#``cgN", { silent = true, desc = "Replace word reverse" })

vim.keymap.set(
  "n",
  "<leader>bf",
  "<CMD>call setreg('+', expand('%:t'))<CR>",
  { desc = "Copy current buffer file name to clipboard" }
)

vim.keymap.set(
  "n",
  "<leader>bF",
  "<CMD>call setreg('+', expand('%:p'))<CR>",
  { desc = "Copy current buffer file path to clipboard" }
)

-- vim.keymap.set("i", "<C-a>", "<Esc>I", { silent = true, desc = "Goto start of line" })
-- vim.keymap.set("i", "<C-e>", "<Esc>A", { silent = true, desc = "Goto end of line" })

-- Copy/paste with system clipboard
vim.keymap.set({ "n", "x" }, "<leader>y", '"+y', { desc = "Copy to system clipboard" })
vim.keymap.set("v", "p", [["_dP]], { desc = "Keep the yanked text when pasting in visual mode" })

-- Add empty lines before and after cursor line supporting dot-repeat
MiniBasics = {}
MiniBasics.put_empty_line = function(put_above)
  -- This has a typical workflow for enabling dot-repeat:
  -- - On first call it sets `operatorfunc`, caches data, and calls
  --   `operatorfunc` on current cursor position.
  -- - On second call it performs task: puts `v:count1` empty lines
  --   above/below current line.
  if type(put_above) == "boolean" then
    vim.o.operatorfunc = "v:lua.MiniBasics.put_empty_line"
    MiniBasics.cache_empty_line = { put_above = put_above }
    return "g@l"
  end

  local target_line = vim.fn.line(".") - (MiniBasics.cache_empty_line.put_above and 1 or 0)
  vim.fn.append(target_line, vim.fn["repeat"]({ "" }, vim.v.count1))
end

vim.keymap.set("n", "gO", "v:lua.MiniBasics.put_empty_line(v:true)", { expr = true, desc = "Put empty line above" })
vim.keymap.set("n", "go", "v:lua.MiniBasics.put_empty_line(v:false)", { expr = true, desc = "Put empty line below" })

-- vim.keymap.set("i", "jjj", "<Esc>", { desc = "Escape Insert mode" })

vim.keymap.set({ "n" }, "H", "^", { desc = "Begin of line" })
vim.keymap.set({ "n" }, "L", "$", { desc = "End of line" })

vim.keymap.set("n", "<Esc>", ":noh<CR>:w<CR>", { silent = true, desc = "Save" })

vim.keymap.set("n", "s", "ciw", { desc = "ciw" })
vim.keymap.set("n", "X", "daw", { desc = "daw" })

vim.keymap.set("n", "<leader>r", ":%s/", { desc = "Start replace" })
vim.keymap.set("v", "<leader>r", '"zy<ESC>:%s/<C-R>z//g<Left><Left>', { desc = "Start replace" })

vim.cmd([[command! Qa :qa]])
vim.cmd([[command! Q :q]])

vim.keymap.set("n", "<leader>'", ":%s/\\(.*\\)/'\\1',/g<CR><ESC>", { desc = "Wrap line with quote" })
vim.keymap.set("n", '<leader>"', ':%s/\\(.*\\)/"\\1",/g<CR><ESC>', { desc = "Wrap line with quote" })

vim.keymap.set("n", "yc", function()
  vim.api.nvim_feedkeys("yygccp", "m", false)
end, { desc = "Copy line and comment" })

vim.keymap.set("v", "gyc", function()
  vim.api.nvim_feedkeys("y'>pgvgc'>j", "m", false)
end, { desc = "Copy line and comment visual" })
