return {
  "nvim-telescope/telescope.nvim",
  keys = {
    {
      "<leader>see",
      function()
        require("telescope.builtin").live_grep({ cwd = require("telescope.utils").buffer_dir() })
      end,
      desc = "[Telescope] live grep current dir",
    },
    {
      "<leader>se1",
      function()
        require("telescope.builtin").live_grep({ cwd = vim.fn.expand("%:p:h:h") })
      end,
      desc = "[Telescope] live grep 1",
    },
    {
      "<leader>se2",
      function()
        require("telescope.builtin").live_grep({ cwd = vim.fn.expand("%:p:h:h:h") })
      end,
      desc = "[Telescope] live grep 2",
    },
    {
      "<leader>se3",
      function()
        require("telescope.builtin").live_grep({ cwd = vim.fn.expand("%:p:h:h:h:h") })
      end,
      desc = "[Telescope] live grep 3",
    },
  },
}
