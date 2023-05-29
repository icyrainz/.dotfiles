return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 500
  end,
  config = function()
    require("which-key").register({
      u = { desc = "Undo" },
      K = { desc = "[LSP] Hover" },
      ["<F2>"] = { desc = "[LSP] Rename" },
      cr = {
        name = "+coercion",
        s = { desc = "Snake Case" },
        _ = { desc = "Snake Case" },
        m = { desc = "Mixed Case" },
        c = { desc = "Camel Case" },
        u = { desc = "Snake Upper Case" },
        U = { desc = "Snake Upper Case" },
        k = { desc = "Kebab Case" },
        t = { desc = "Title Case (not reversible)" },
        ["-"] = { desc = "Kebab Case (not reversible)" },
        ["."] = { desc = "Dot Case (not reversible)" },
        ["<space>"] = { desc = "Space Case (not reversible)" },
      },
      ["<leader>"] = {
        b = { name = "+buffer" },
        c = { name = "+copy" },
        d = { name = "+dap" },
        f = { name = "+file" },
        g = {
          name = "+git",
          b = { name = "+blame" },
          d = { name = "+diffview" },
          w = { name = "+worktree" },
        },
        h = { name = "+harpoon" },
        l = { name = "+leap" },
        n = { name = "+chatgpt" },
        s = { name = "+symbols" },
        w = { name = "+window" },
        x = { name = "+trouble" },
        [","] = { desc = "Toggle end of line ','" },
        [";"] = { desc = "Toggle end of line ';'" },
      }
    })
  end
}
