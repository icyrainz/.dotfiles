return {
  "tamago324/lir.nvim",
  config = function()
    local actions = require 'lir.actions'
    local mark_actions = require 'lir.mark.actions'
    local clipboard_actions = require 'lir.clipboard.actions'

    require('lir').setup {
      show_hidden_files = false,
      ignore = {}, -- { ".DS_Store", "node_modules" } etc.
      devicons = {
        enable = false,
        highlight_dirname = true
      },
      mappings = {
        ['l']     = actions.edit,
        ['<CR>']  = actions.edit,
        ['<C-s>'] = actions.split,
        ['<C-v>'] = actions.vsplit,
        ['<C-t>'] = actions.tabedit,

        ['h']     = actions.up,
        ['<BS>']  = actions.up,
        ['q']     = actions.quit,
        ['<ESC>'] = actions.quit,

        ['K']     = actions.mkdir,
        ['N']     = actions.newfile,
        ['R']     = actions.rename,
        ['@']     = actions.cd,
        ['Y']     = actions.yank_path,
        ['.']     = actions.toggle_show_hidden,
        ['D']     = actions.delete,

        ['J']     = function()
          mark_actions.toggle_mark()
          vim.cmd('normal! j')
        end,
        ['C']     = clipboard_actions.copy,
        ['X']     = clipboard_actions.cut,
        ['P']     = clipboard_actions.paste,

      },
      float = {
        winblend = 0,
        curdir_window = {
          enable = false,
          highlight_dirname = false
        },
      },
      hide_cursor = true
    }

    vim.keymap.set("n", "-", "<Cmd>lua require'lir.float'.toggle()<CR>", { noremap = true, silent = true })
  end,
}
