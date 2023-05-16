return {
  "AckslD/nvim-neoclip.lua",
  config = function()
    require('neoclip').setup()
    require('telescope').load_extension('neoclip')

    vim.api.nvim_set_keymap('n', '<leader>fv', ':Telescope neoclip<CR>',
      { noremap = true, silent = true, desc = "Open neoclip" })
  end,
}