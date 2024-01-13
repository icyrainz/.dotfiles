local M = {}

local toggle = function(character)
  local api = vim.api
  local delimiters = { ",", ";" }
  local line = api.nvim_get_current_line()
  local filetype = vim.bo.filetype

  -- Define comment delimiters for different file types
  local comment_delimiters = {
    lua = "%-%-", -- Lua comment
    javascript = "//", -- JavaScript comment
    typescript = "//", -- TypeScript comment
    -- Add more file types and their comment delimiters as needed
  }

  -- Get the appropriate comment delimiter for the current file type
  local comment_delimiter = comment_delimiters[filetype] or "//"

  -- Find the position of the EOL comment
  local comment_start = line:find("%s*" .. comment_delimiter)
  local end_pos = comment_start and (comment_start - 1) or #line

  -- Extract the substring before the comment
  local before_comment = line:sub(1, end_pos)
  local last_char = before_comment:sub(-1)

  -- Perform the toggle operation
  if last_char == character then
    before_comment = before_comment:sub(1, #before_comment - 1)
  elseif vim.tbl_contains(delimiters, last_char) then
    before_comment = before_comment:sub(1, #before_comment - 1) .. character
  else
    before_comment = before_comment .. character
  end

  -- Reconstruct the line with the comment, if present
  local new_line = comment_start and (before_comment .. line:sub(comment_start)) or before_comment
  return api.nvim_set_current_line(new_line)
end

vim.keymap.set("n", "<leader>;", function()
  toggle(";")
end, { desc = "Toggle ; EOL" })
vim.keymap.set("n", "<leader>,,", function()
  toggle(",")
end, { desc = "Toggle , EOL" })

return M
