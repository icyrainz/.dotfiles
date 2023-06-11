return {
  "glepnir/lspsaga.nvim",
  event = "LspAttach",
  dependencies = {
    { "nvim-tree/nvim-web-devicons" },
    --Please make sure you install markdown and markdown_inline parser
    { "nvim-treesitter/nvim-treesitter" },
  },
  keys = {
    { "<leader>sO",  "<CMD>Lspsaga outline<CR>",                    desc = "Lspsaga outline" },
    { "<leader>sf",  "<CMD>Lspsaga lsp_finder<CR>",                 desc = "Lspsaga finder" },
    { "<leader>sa",  "<CMD>Lspsaga code_action<CR>",                desc = "Lspsaga code action" },
    { "<leader>sr",  "<CMD>Lspsaga rename ++project<CR>",           desc = "Lspsaga rename (project)" },
    { "<leader>spd", "<CMD>Lspsaga peek_definition<CR>",            desc = "Lspsaga peek definition" },
    { "<leader>spt", "<CMD>Lspsaga peek_type_definition<CR>",       desc = "Lspsaga peek type definition" },
    { "<leader>sci", "<CMD>Lspsaga incoming_calls<CR>",             desc = "Lspsaga incoming calls" },
    { "<leader>sco", "<CMD>Lspsaga outgoing_calls<CR>",             desc = "Lspsaga outgoing calls" },
    { "<leader>sdw", "<CMD>Lspsaga show_workspace_diagnostics<CR>", desc = "Lspsaga workspace diagnostics" },
    { "<leader>sdb", "<CMD>Lspsaga show_buf_diagnostics<CR>",       desc = "Lspsaga buf diagnostics" },
    { "<leader>sdl", "<CMD>Lspsaga show_line_diagnostics<CR>",      desc = "Lspsaga line diagnostics" },
    { "<leader>sdc", "<CMD>Lspsaga show_cursor_diagnostics<CR>",    desc = "Lspsaga cursor diagnostics" },
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
