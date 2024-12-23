return {
  {
    "nvim-telescope/telescope-dap.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("telescope").load_extension("dap")
    end,
  },
  {
    "mfussenegger/nvim-dap",

  -- stylua: ignore
  keys = {
    { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
    { "<leader>dn", function() require("dap").step_over() end, desc = "Step Over" },
    { "<leader>dd", function() require("dap").clear_breakpoints() end, desc = "Remove all breakpoints" },
    { "<F6>", function() require("dap").toggle_breakpoint() end, "[DAP] Toggle breakpoint" },
    { "<F7>", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, "[DAP] Set breakpoint" },
    { "<F8>", function() require("dap").run_last() end, "[DAP] Run last" },
    { "<F9>", function() require("dap").continue() end, "[DAP] Continue" },
    { "<F10>", function() require("dap").step_over() end, "[DAP] Step over" },
    { "<F11>", function() require("dap").step_into() end, "[DAP] Step into" },
    { "<F12>", function() require("dap").step_out() end, "[DAP] Step out" },
  },

    opts = function()
      local dap = require("dap")

      if not dap.adapters["pwa-node"] then
        require("dap").adapters["pwa-node"] = {
          type = "server",
          host = "localhost",
          port = "${port}",
          executable = {
            command = "node",
            -- 💀 Make sure to update this path to point to your installation
            args = {
              require("mason-registry").get_package("js-debug-adapter"):get_install_path()
                .. "/js-debug/src/dapDebugServer.js",
              "${port}",
            },
          },
          enrich_config = function(config, on_config)
            local final_config = vim.deepcopy(config)
            final_config.cwd = vim.fn.getcwd()
            final_config.sourceMaps = true

            on_config(final_config)
          end,
        }
      end

      if not dap.adapters["node"] then
        dap.adapters["node"] = function(cb, config)
          if config.type == "node" then
            config.type = "pwa-node"
          end
          local nativeAdapter = dap.adapters["pwa-node"]
          if type(nativeAdapter) == "function" then
            nativeAdapter(cb, config)
          else
            cb(nativeAdapter)
          end
        end
      end
    end,
  },
}
