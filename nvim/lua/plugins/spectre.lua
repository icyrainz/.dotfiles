return {
  'nvim-pack/nvim-spectre',
  keys = {
    { "<leader>S",  '<CMD>lua require("spectre").open()<CR>',                          desc = "[spectre] open" },
    { "<leader>Sw", '<CMD>lua require("spectre").open_visual({select_word=true})<CR>', desc = "[spectre] search word" },
    {
      "<leader>Sw",
      '<esc><CMD>lua require("spectre").open_visual()<CR>',
      mode = "v",
      desc = "[spectre] search word",
    },
    {
      "<leader>Sp",
      '<CMD>lua require("spectre").open_file_search({select_word=true})<CR>',
      desc = "Search on current file",
    }
  },
  opts = {},
}
