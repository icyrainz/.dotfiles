return {
  {
    "rcarriga/nvim-dap-ui",
    opts = {
      layouts = {
        {
          elements = {
            {
              id = "scopes",
              size = 0.5,
            },
            {
              id = "breakpoints",
              size = 0.25,
            },
            -- {
            --   id = "stacks",
            --   size = 0.25
            -- } ,
            {
              id = "watches",
              size = 0.25,
            },
          },
          position = "right",
          size = 10,
        },
        {
          elements = {
            {
              id = "console",
              size = 0.75,
            },
            -- {
            --   id = "repl",
            --   size = 0.5
            -- }
          },
          position = "bottom",
          size = 15,
        },
      },
    },
    config = function(_, opts)
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup(opts)
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open({})
      end
      -- dap.listeners.before.event_terminated["dapui_config"] = function()
      --   dapui.close({})
      -- end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close({})
      end
    end,
  },
  {
    "folke/edgy.nvim",
    opts = function(_, opts)
      opts.right = opts.right or {}
      table.insert(opts.right, {
        title = "Scopes",
        ft = "dapui_scopes",
        pinned = false,
      })
      table.insert(opts.right, {
        title = "Breakpoints",
        ft = "dapui_breakpoints",
        pinned = false,
      })
      table.insert(opts.right, {
        title = "Watches",
        ft = "dapui_watches",
        pinned = false,
      })

      opts.bottom = opts.bottom or {}
      table.insert(opts.bottom, {
        title = "Console",
        ft = "dapui_console",
        pinned = false,
      })
    end,
  },
}
