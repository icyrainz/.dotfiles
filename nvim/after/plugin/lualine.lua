local git_blame = require("gitblame")
local lualine = require("lualine")

lualine.setup({
  sections = {
    lualine_c = {
      { git_blame.get_current_blame_text, cond = git_blame.is_blame_text_available },
    },
    lualine_x = {
      {
        require('cool-substitute.status').status_with_icons,
        color = function() return { fg = require('cool-substitute.status').status_color() } end
      },
      'encoding',
      'fileformat',
      'filetype'
    },
  },
})
