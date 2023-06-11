return {
  {
    "stevearc/qf_helper.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>q", "<CMD>QFToggle<CR>",  desc = "Close quickfix" },
      { "<leader>Q", "<CMD>QFToggle!<CR>", desc = "Close quickfix!" },
    },
    opts = {
      quickfix = {
        autoclose = true,         -- Autoclose qf if it's the only open window
        default_bindings = false, -- Set up recommended bindings in qf window
        default_options = true,   -- Set recommended buffer and window options
        max_height = 10,          -- Max qf height when using open() or toggle()
        min_height = 1,           -- Min qf height when using open() or toggle()
        track_location = true,    -- Keep qf updated with your current location
      },
    },
  },
  {
    "kevinhwang91/nvim-bqf",
    event = "VeryLazy",
    opts = {
      preview = {
        -- auto_preview = false,
        border = "none",
      },
    },
    init = function()
      vim.api.nvim_set_hl(0, "BqfPreviewBorder", {
        link = "TelescopePreviewBorder",
      })
    end,
  },
}
