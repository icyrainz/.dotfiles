local extension_path = vim.env.HOME .. '/.vscode/extensions/vadimcn.vscode-lldb-1.9.0/'
local codelldb_path = extension_path .. 'adapter/codelldb'
local liblldb_path = extension_path .. 'lldb/lib/liblldb.dylib'

local opt = {
    tools = {
        hover_actions = {
            auto_focus = true,
        },
    },
    server = {
        on_attach = function(client, bufnr)
            vim.keymap.set("n", "<C-Space>", require("rust-tools").hover_actions.hover_actions, { buffer = bufnr })
        end,
    },
    dap = {
        adapter = require('rust-tools.dap').get_codelldb_adapter(codelldb_path, liblldb_path),
    },
}

require('rust-tools').setup(opt)

local function opts(desc)
  return { desc = 'rust: ' .. desc }
end

vim.keymap.set("n", "<leader>rr", ":RustRunnables<CR>", opts("Runnables"))
vim.keymap.set("n", "<leader>rd", ":RustDebuggables<CR>", opts("Debuggables"))
vim.keymap.set("n", "<leader>ra", ":RustCodeAction<CR>", opts("Code action"))
vim.keymap.set("n", "<leader>rh", ":RustHoverActions<CR>", opts("Hover actions"))
vim.keymap.set("n", "<leader>ri", ":RustEnableInlayHints<CR>", opts("Enable inlay hints"))
vim.keymap.set("n", "<leader>ro", ":RustDisableInlayHints<CR>", opts("Disable inlay hints"))

vim.keymap.set("n", "<leader>rb", ":Cbuild<CR>", opts("Cargo Build"))
vim.keymap.set("n", "<F5>", ":Crun<CR>", opts("Cargo Run"))

vim.keymap.set("n", "<leader>rf", ":RustFmt<CR>", opts("Format"))
