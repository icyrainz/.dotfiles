local M = {}

local dap = require("dap")
local dap_utils = require("dap.utils")

dap.adapters["pwa-node"] = dap.adapters.node2

require("dap.ext.vscode").load_launchjs(nil, { ["pwa-node"] = { "typescript" } })

for i, config in ipairs(dap.configurations.typescript or {}) do
  dap.configurations.typescript[i] = vim.tbl_deep_extend("force", config, {
    cwd = vim.fn.getcwd(),
    sourceMaps = true,
  })
end

return M
