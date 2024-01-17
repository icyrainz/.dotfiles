return {
  "mfussenegger/nvim-dap",

  -- stylua: ignore
  keys = {
    { "<F9>", function() require("dap").continue() end, "[DAP] Continue" },
    { "<F10>", function() require("dap").step_over() end, "[DAP] Step over" },
    { "<F11>", function() require("dap").step_into() end, "[DAP] Step into" },
    { "<F12>", function() require("dap").step_out() end, "[DAP] Step out" },
  },
  opts = function()
    local dap = require("dap")

    dap.adapters["pwa-node"] = dap.adapters.node2

    print(dap.adapters["pwa-node"])

    require("dap.ext.vscode").load_launchjs(nil, { ["pwa-node"] = { "typescript" } })

    for i, config in ipairs(dap.configurations.typescript or {}) do
      dap.configurations.typescript[i] = vim.tbl_deep_extend("force", config, {
        cwd = vim.fn.getcwd(),
        sourceMaps = true,
      })
    end
  end,
}
