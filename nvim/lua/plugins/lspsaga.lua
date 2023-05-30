return {
  "glepnir/lspsaga.nvim",
  event = "LspAttach",
  dependencies = {
    { "nvim-tree/nvim-web-devicons" },
    --Please make sure you install markdown and markdown_inline parser
    { "nvim-treesitter/nvim-treesitter" },
  },
  init = function()
    vim.keymap.set("n", "<leader>so", "<cmd>Lspsaga outline<CR>", { desc = "Lspsaga outline" })
    vim.keymap.set("n", "<leader>sh", "<cmd>Lspsaga lsp_finder<CR>", { desc = "Lspsaga finder" })
    vim.keymap.set("n", "<leader>sa", "<cmd>Lspsaga code_action<CR>", { desc = "Lspsaga code action" })
    vim.keymap.set("n", "<leader>sr", "<cmd>Lspsaga rename ++project<CR>", { desc = "Lspsaga rename (project)" })
    vim.keymap.set("n", "<leader>sp", "<cmd>Lspsaga peek_definition<CR>", { desc = "Lspsaga peek definition" })
    vim.keymap.set("n", "<leader>se", "<cmd>Lspsaga peek_type_definition<CR>", { desc = "Lspsaga peek type definition" })
    vim.keymap.set("n", "<leader>sc", "<cmd>Lspsaga incoming_calls<CR>", { desc = "Lspsaga incoming calls" })
    vim.keymap.set("n", "<leader>sC", "<cmd>Lspsaga outgoing_calls<CR>", { desc = "Lspsaga outgoing calls" })
  end,
  -- opts = {
  -- },
  config = function()
    require('lspsaga').setup({
      symbol_in_winbar = {
        folder_level = 4,
        ignore_patterns = {
          "oil://*",
        }
      },
      lightbulb = {
        virtual_text = false,
      },
      ui = {
        code_action = '',
      },
      outline = {
        auto_preview = false,
      },
    })
    vim.cmd [[
      augroup disable_winbar
      autocmd!
      autocmd FileType oil setlocal winbar=""
      augroup END
    ]]
  end,
}
