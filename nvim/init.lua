require("core.set")
require("core.mappings")
require("core.lazy")

function SourceDirLocals()
  local dir_locals_path = vim.fn.expand('%:p:h') .. '/.dir-locals.lua'
  if vim.fn.filereadable(dir_locals_path) == 1 then
    vim.cmd('luafile ' .. dir_locals_path)
  end
end

vim.cmd [[
augroup project_specific
  autocmd!
  autocmd BufEnter * lua SourceDirLocals()
augroup END
]]
