return {
  "mrjones2014/smart-splits.nvim",
  event = "VeryLazy",
  opts = {
    at_edge = "stop",
  },
  keys = {
			-- stylua: ignore start
    { "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Move cursor left", },
    { "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Move cursor down", },
    { "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Move cursor up", },
    { "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Move cursor right", },
    { "<C-Left>", function() require("smart-splits").resize_left() end, desc = "Resize left", },
    { "<C-Down>", function() require("smart-splits").resize_down() end, desc = "Resize down", },
    { "<C-Up>", function() require("smart-splits").resize_up() end, desc = "Resize up", },
    { "<C-Right>", function() require("smart-splits").resize_right() end, desc = "Resize right", },
    { "<leader>wk", function() require("smart-splits").swap_buf_up() end, desc = "Swap buffer up", },
    { "<leader>wj", function() require("smart-splits").swap_buf_down() end, desc = "Swap buffer down", },
    { "<leader>wl", function() require("smart-splits").swap_buf_right() end, desc = "Swap buffer right", },
    { "<leader>wh", function() require("smart-splits").swap_buf_left() end, desc = "Swap buffer left", },
    { "<leader>wr", function() require("smart-splits").start_resize_mode() end, desc = "Window resize mode",
			-- stylua: ignore end
    },
  },
}
