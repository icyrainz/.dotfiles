local function key_opts(key, action, desc)
  return { key, action, desc = desc, ft = { "typescript", "typescriptreact", "typescript.tsx" } }
end

return {
  "pmizio/typescript-tools.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "neovim/nvim-lspconfig",
    {
      "folke/which-key.nvim",
      opts = {
        defaults = {
          ["<leader>ct"] = { name = "+typescript-tools" },
          ["<leader>cti"] = { name = "+imports" },
        },
      },
    },
    {
      "nvim-treesitter/nvim-treesitter",
      opts = function(_, opts)
        if type(opts.ensure_installed) == "table" then
          vim.list_extend(opts.ensure_installed, { "typescript", "tsx" })
        end
      end,
    },
    {
      "williamboman/mason.nvim",
      opts = function(_, opts)
        opts.ensure_installed = opts.ensure_installed or {}
        table.insert(opts.ensure_installed, "js-debug-adapter")
      end,
    },
  },
  opts = {},
  ft = { "typescript", "typescriptreact", "typescript.tsx" },
  keys = {
    key_opts("<leader>ctio", ":TSToolsOrganizeImports<CR>", "Organize Imports"),
    key_opts("<leader>ctis", ":TSToolsSortImports<CR>", "Sort Imports"),
    key_opts("<leader>ctia", ":TSToolsAddMissingImports<CR>", "Add Missing Imports"),
    key_opts("<leader>ctir", ":TSToolsRemoveUnusedImports<CR>", "Remove Unused Imports"),
    key_opts("<leader>ctf", ":TSToolsFixAll<CR>", "Fix All"),
    key_opts("<leader>ctr", ":TSToolsRenameFile<CR>", "Rename File"),
    key_opts("<leader>ctg", ":TSToolsGoToSourceDefinition<CR>", "Goto Source Definition"),
  },
}
