return {
  "glepnir/lspsaga.nvim",
  event = "LspAttach",
  dependencies = {
    { "nvim-tree/nvim-web-devicons" },
    --Please make sure you install markdown and markdown_inline parser
    { "nvim-treesitter/nvim-treesitter" },
  },
  keys = {
    { "<leader>sO",  "<cmd>Lspsaga outline<CR>",                    desc = "Lspsaga outline" },
    { "<leader>sf",  "<cmd>Lspsaga lsp_finder<CR>",                 desc = "Lspsaga finder" },
    { "<leader>sa",  "<cmd>Lspsaga code_action<CR>",                desc = "Lspsaga code action" },
    { "<leader>sr",  "<cmd>Lspsaga rename ++project<CR>",           desc = "Lspsaga rename (project)" },
    { "<leader>spd", "<cmd>Lspsaga peek_definition<CR>",            desc = "Lspsaga peek definition" },
    { "<leader>spt", "<cmd>Lspsaga peek_type_definition<CR>",       desc = "Lspsaga peek type definition" },
    { "<leader>sci", "<cmd>Lspsaga incoming_calls<CR>",             desc = "Lspsaga incoming calls" },
    { "<leader>sco", "<cmd>Lspsaga outgoing_calls<CR>",             desc = "Lspsaga outgoing calls" },
    { "<leader>sdw", "<cmd>Lspsaga show_workspace_diagnostics<CR>", desc = "Lspsaga workspace diagnostics" },
    { "<leader>sdb", "<cmd>Lspsaga show_buf_diagnostics<CR>",       desc = "Lspsaga buf diagnostics" },
    { "<leader>sdl", "<cmd>Lspsaga show_line_diagnostics<CR>",      desc = "Lspsaga line diagnostics" },
    { "<leader>sdc", "<cmd>Lspsaga show_cursor_diagnostics<CR>",    desc = "Lspsaga cursor diagnostics" },
  },
  -- opts = {
  -- },
  config = function()
    require('lspsaga').setup({
      symbol_in_winbar = {
        folder_level = 0,
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
