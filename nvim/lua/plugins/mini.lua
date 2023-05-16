return {
  "echasnovski/mini.nvim",
  config = function()
    require('mini.ai').setup()

    require('mini.basics').setup()

    require('mini.animate').setup()
    --
    require('mini.bracketed').setup()

    require('mini.bufremove').setup()

    require('mini.comment').setup()

    require('mini.splitjoin').setup()

    require('mini.surround').setup()

    require('mini.indentscope').setup()

    -- require('mini.jump').setup()

    require('mini.pairs').setup()

    require('mini.move').setup({
      mappings = {
        -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
        left = 'H',
        right = 'L',
        down = 'J',
        up = 'K',
      }
    })

    require('mini.cursorword').setup()

    require('mini.map').setup()
    vim.keymap.set('n', '<leader>mc', MiniMap.close, { desc = 'Close MiniMap' })
    vim.keymap.set('n', '<leader>mf', MiniMap.toggle_focus, { desc = 'Toggle MiniMap focus' })
    vim.keymap.set('n', '<leader>mo', MiniMap.open, { desc = 'Open MiniMap' })
    vim.keymap.set('n', '<leader>mr', MiniMap.refresh, { desc = 'Refresh MiniMap' })
    vim.keymap.set('n', '<leader>ms', MiniMap.toggle_side, { desc = 'Toggle MiniMap sidebar' })
    vim.keymap.set('n', '<leader>mt', MiniMap.toggle, { desc = 'Toggle MiniMap' })

    -- require('mini.tabline').setup()
    -- require('mini.statusline').setup()

    require('mini.trailspace').setup()

    -- require('mini.starter').setup()

    require('mini.sessions').setup()
  end,
}
