return {
  'mrjones2014/smart-splits.nvim',
  config = true,
  keys = {
    { '<leader>wk', function() require('smart-splits').swap_buf_up() end,    desc = "Swap buffer up" },
    { '<leader>wj', function() require('smart-splits').swap_buf_down() end,  desc = "Swap buffer down" },
    { '<leader>wl', function() require('smart-splits').swap_buf_right() end, desc = "Swap buffer right" },
    { '<leader>wh', function() require('smart-splits').swap_buf_left() end,  desc = "Swap buffer left" },

    { '<leader>wr', function() require('smart-splits').start_resize_mode() end,  desc = "Window resize mode" },
  },
}
