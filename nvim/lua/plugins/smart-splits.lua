return {
  'mrjones2014/smart-splits.nvim',
  config = true,
  keys = {
    -- { '<A-Up>',     function() require('smart-splits').resize_up(2) end,     desc = "Resize up" },
    -- { '<A-Down>',   function() require('smart-splits').resize_down(2) end,   desc = "Resize down" },
    -- { '<A-Left>',   function() require('smart-splits').resize_left(5) end,   desc = "Resize left" },
    -- { '<A-Right>',  function() require('smart-splits').resize_right(5) end,  desc = "Resize right" },
    { '<leader>wk', function() require('smart-splits').swap_buf_up() end,    desc = "Swap buffer up" },
    { '<leader>wj', function() require('smart-splits').swap_buf_down() end,  desc = "Swap buffer down" },
    { '<leader>wl', function() require('smart-splits').swap_buf_right() end, desc = "Swap buffer right" },
    { '<leader>wh', function() require('smart-splits').swap_buf_left() end,  desc = "Swap buffer left" },

    { '<leader>wr', function() require('smart-splits').start_resize_mode() end,  desc = "Window resize mode" },
  },
}
