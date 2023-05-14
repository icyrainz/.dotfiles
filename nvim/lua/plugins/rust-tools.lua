return {
  "simrat39/rust-tools.nvim",
  dependencies = {
    'neovim/nvim-lspconfig',
    'nvim-lua/plenary.nvim',
    'mfussenegger/nvim-dap',
  },
  opts = function()
    local extension_path = vim.env.HOME .. '/.vscode/extensions/vadimcn.vscode-lldb-1.9.0/'
    local codelldb_path = extension_path .. 'adapter/codelldb'
    local liblldb_path = extension_path .. 'lldb/lib/liblldb.dylib'
    return {
      tools = {
        hover_actions = {
          auto_focus = true,
        },
      },
      server = {
        on_attach = function(client, bufnr)
          vim.keymap.set("n", "<leader>rr", ":RustRunnables<CR>", { buffer = bufnr, desc = "Rust: Runnables" })
          vim.keymap.set("n", "<leader>rd", ":RustDebuggables<CR>", { buffer = bufnr, desc = "Rust: Debuggables" })
          vim.keymap.set("n", "<leader>ra", ":RustCodeAction<CR>", { buffer = bufnr, desc = "Rust: Code action" })
          vim.keymap.set("n", "<leader>rh", ":RustHoverActions<CR>", { buffer = bufnr, desc = "Hover actions" })
          vim.keymap.set("n", "<leader>ri", ":RustEnableInlayHints<CR>",
            { buffer = bufnr, desc = "Rust: Enable inlay hints" })
          vim.keymap.set("n", "<leader>ro", ":RustDisableInlayHints<CR>",
            { buffer = bufnr, desc = "Rust: Disable inlay hints" })

          vim.keymap.set("n", "<leader>cb", ":Cbuild<CR>", { buffer = bufnr, desc = "Cargo: Build" })
          vim.keymap.set("n", "<leader>cr", ":Crun<CR>", { buffer = bufnr, desc = "Cargo: Run" })

          vim.keymap.set("n", "<leader>rf", ":RustFmt<CR>", { buffer = bufnr, desc = "Rust: Format" })
        end,
      },
      dap = {
        adapter = require('rust-tools.dap').get_codelldb_adapter(codelldb_path, liblldb_path),
      },
    }
  end,
}
