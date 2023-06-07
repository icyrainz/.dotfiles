return {
  {
    "stevearc/qf_helper.nvim",
    config = function()
      vim.keymap.set("n", "<leader>q", ":QFToggle<CR>", { desc = "Close quickfix" })
      vim.keymap.set("n", "<leader>Q", ":QFToggle!<CR>", { desc = "Close quickfix!" })

      require('qf_helper').setup({
        quickfix = {
          autoclose = true,         -- Autoclose qf if it's the only open window
          default_bindings = false, -- Set up recommended bindings in qf window
          default_options = true,   -- Set recommended buffer and window options
          max_height = 10,          -- Max qf height when using open() or toggle()
          min_height = 1,           -- Min qf height when using open() or toggle()
          track_location = true,    -- Keep qf updated with your current location
        },
      })
    end,
  },
  {
    "kevinhwang91/nvim-bqf",
    config = function()
      vim.cmd([[
          hi link BqfPreviewFloat TelescopePreviewNormal
      ]])

      require('bqf').setup({
        preview = {
          -- auto_preview = false,
          border = "none",
        },
      })
    end
  },
}
