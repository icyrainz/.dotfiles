function SetColor(color)
  color = color or "rose-pine"
  vim.cmd.colorscheme(color)

  -- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  -- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
  -- vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#330000" })
end

-- SetColor()
SetColor("kanagawa-wave")
-- SetColor("nightly")
-- SetColor("tokyonight-moon")
-- SetColor('catppuccin')

local colors = require("kanagawa.colors").setup()
local palette_colors = colors.palette

vim.api.nvim_set_hl(0, "MiniTablineCurrent", {
  bg = palette_colors.sumiInk5,
})
vim.api.nvim_set_hl(0, "MiniTablineVisible", {
  bg = "none"
})
vim.api.nvim_set_hl(0, "MiniTablineHidden", {
  bg = "none"
})
vim.api.nvim_set_hl(0, "MiniTablineModifiedCurrent", {
  fg = palette_colors.lotusOrange,
  bg = palette_colors.sumiInk5,
})
vim.api.nvim_set_hl(0, "MiniTablineModifiedVisible", {
  fg = palette_colors.lotusOrange2,
})
vim.api.nvim_set_hl(0, "MiniTablineModifiedHidden", {
  fg = palette_colors.lotusOrange2,
})
