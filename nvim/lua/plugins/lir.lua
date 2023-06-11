return {
  {
    "tamago324/lir.nvim",
    keys = {
      { "-", "<Cmd>lua require'lir.float'.toggle()<CR>", noremap = true, silent = true },
    },
    config = function()
      local actions = require 'lir.actions'
      local mark_actions = require 'lir.mark.actions'
      local clipboard_actions = require 'lir.clipboard.actions'

      require('lir').setup {
        show_hidden_files = false,
        ignore = {}, -- { ".DS_Store", "node_modules" } etc.
        devicons = {
          enable = true,
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

          ['A']     = actions.mkdir,
          ['a']     = actions.newfile,
          ['r']     = actions.rename,
          ['@']     = actions.cd,
          ['Y']     = actions.yank_path,
          ['H']     = actions.toggle_show_hidden,
          ['d']     = actions.delete,

          ['J']     = function()
            mark_actions.toggle_mark()
            vim.cmd('normal! j')
          end,
          ['c']     = clipboard_actions.copy,
          ['x']     = clipboard_actions.cut,
          ['p']     = clipboard_actions.paste,
        },
        float = {
          winblend = 0,
          curdir_window = {
            enable = false,
            highlight_dirname = false
          },
        },
        hide_cursor = true,
      }

      vim.api.nvim_create_autocmd({ 'FileType' }, {
        pattern = { "lir" },
        callback = function()
          -- use visual mode
          vim.api.nvim_buf_set_keymap(
            0,
            "x",
            "J",
            ':<C-u>lua require"lir.mark.actions".toggle_mark("v")<CR>',
            { noremap = true, silent = true }
          )

          -- echo cwd
          vim.api.nvim_echo({ { vim.fn.expand("%:~"), "Normal" } }, false, {})
        end
      })

      vim.api.nvim_set_hl(0, "LirFloatNormal", {
        link = "TelescopeResultsNormal",
      })
    end,
  },
}
