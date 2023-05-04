
local function opts(desc)
  return { desc = 'dap: ' .. desc }
end

vim.keymap.set('n', '<F9>', function() require('dap').continue() end, opts("continue"))
vim.keymap.set('n', '<F6>', function() require('dap').terminate() end, opts("terminate"))
vim.keymap.set('n', '<F10>', function() require('dap').step_over() end, opts("step over"))
vim.keymap.set('n', '<F11>', function() require('dap').step_into() end, opts("step into"))
vim.keymap.set('n', '<F12>', function() require('dap').step_out() end, opts("step out"))
vim.keymap.set('n', '<Leader>db', function() require('dap').toggle_breakpoint() end, opts("toggle breakpoint"))
vim.keymap.set('n', '<Leader>dB', function() require('dap').set_breakpoint() end, opts("set breakpoint"))
vim.keymap.set('n', '<Leader>dm', function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end, opts("Log point"))
vim.keymap.set('n', '<Leader>dr', function() require('dap').repl.open() end, opts("open REPL"))
vim.keymap.set('n', '<Leader>dl', function() require('dap').run_last() end, opts("run last"))
vim.keymap.set({'n', 'v'}, '<Leader>dh', function()
    require('dap.ui.widgets').hover()
end, opts("hover"))
vim.keymap.set({'n', 'v'}, '<Leader>dp', function()
    require('dap.ui.widgets').preview()
end, opts("preview"))
vim.keymap.set('n', '<Leader>df', function()
    local widgets = require('dap.ui.widgets')
    widgets.centered_float(widgets.frames)
end, opts("frames"))
vim.keymap.set('n', '<Leader>ds', function()
    local widgets = require('dap.ui.widgets')
    widgets.centered_float(widgets.scopes)
end, opts("scopes"))

require("nvim-dap-virtual-text").setup()
require("dapui").setup()

vim.keymap.set('n', '<Leader>dT', function() require('dapui').toggle() end, opts("toggle UI"))
local dap, dapui = require("dap"), require("dapui")
dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end
