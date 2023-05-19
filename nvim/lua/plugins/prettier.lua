return {
  "MunifTanjim/prettier.nvim",
  config = function()
    local prettier = require("prettier")

    prettier.setup({
      bin = "prettierd",
      filetypes = {
        "css",
        "graphql",
        "html",
        "javascript",
        "javascriptreact",
        "json",
        "less",
        "markdown",
        "scss",
        "typescript",
        "typescriptreact",
        "yaml",
      },
      ["null-ls"] = {
        condition = function()
          return prettier.config_exists({
            check_package_json = true,
          })
        end,
      }
    })

    vim.keymap.set("n", "<leader>pf", ":Prettier<CR>", { desc = "Prettier format" })
  end,
}
