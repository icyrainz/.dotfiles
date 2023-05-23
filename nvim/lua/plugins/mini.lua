return {
  "echasnovski/mini.nvim",
  config = function()
    require("mini.ai").setup()

    require("mini.basics").setup({
      autocommands = {
        relnum_in_visual_mode = true,
      },
    })

    require('mini.fuzzy').setup()

    -- require("mini.animate").setup()

    require("mini.bracketed").setup()

    require("mini.bufremove").setup()

    require("mini.comment").setup()

    require("mini.splitjoin").setup()

    require("mini.surround").setup()

    require("mini.indentscope").setup()

    require("mini.jump").setup({
      delay = {
        highlight = 10000000,
      },
    })

    -- require("mini.jump2d").setup()

    -- require("mini.pairs").setup()

    require("mini.move").setup({
      mappings = {
        -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
        left = "H",
        right = "L",
        down = "J",
        up = "K",
      },
    })

    require("mini.cursorword").setup()

    -- require('mini.tabline').setup()
    -- require('mini.statusline').setup()

    require("mini.trailspace").setup()

    require("mini.sessions").setup()

    require('mini.fuzzy').setup()

    -- Mini starter
    local status, starter = pcall(require, "mini.starter")
    if not status then
      return
    end

    starter.setup({
      content_hooks = {
        starter.gen_hook.adding_bullet(""),
        starter.gen_hook.aligning("center", "center"),
        starter.gen_hook.indexing("all", {
          "Actions",
          "Plugins",
          "Builtin actions",
        }),
      },
      evaluate_single = true,
      footer = os.date(),

      header = table.concat({
        [[  /\ \▔\___  ___/\   /(●)_ __ ___  ]],
        [[ /  \/ / _ \/ _ \ \ / / | '_ ` _ \ ]],
        [[/ /\  /  __/ (_) \ V /| | | | | | |]],
        [[\_\ \/ \___|\___/ \_/ |_|_| |_| |_|]],
        [[───────────────────────────────────]],
      }, "\n"),
      query_updaters = [[abcdefghilmnopqrstuvwxyz0123456789_-,.ABCDEFGHIJKLMNOPQRSTUVWXYZ]],
      items = {
        starter.sections.recent_files(9, true, false),
        -- { action = "Telescope find_files", name = "F: Find Files", section = "Telescope" },
        -- { action = "Telescope oldfiles", name = "O: Old Files", section = "Telescope" },
        { action = "FzfLua files",               name = "F: Find Files",      section = "Actions" },
        {
          action = function()
            require("fzf-lua").oldfiles({
              cwd_only = function()
                return vim.api.nvim_command("pwd") ~= vim.env.HOME
              end,
            })
          end,
          name = "O: Old Files",
          section = "Actions"
        },
        { action = "Telescope conduct projects", name = "P: Projects",        section = "Actions" },
        { action = "Neotree toggle float",       name = "E: Explorer",        section = "Actions" },
        { action = "tab G",                      name = "G: Fugitive",        section = "Actions" },
        { action = "Lazy",                       name = "M: Package Manager", section = "Plugins" },
        { action = "enew",                       name = "N: New Buffer",      section = "Builtin actions" },
        { action = "qall!",                      name = "Q: Quit Neovim",     section = "Builtin actions" },
      },
    })

    vim.cmd([[
  augroup MiniStarterJK
    au!
    au User MiniStarterOpened nmap <buffer> j <Cmd>lua MiniStarter.update_current_item('next')<CR>
    au User MiniStarterOpened nmap <buffer> k <Cmd>lua MiniStarter.update_current_item('prev')<CR>
    " au User MiniStarterOpened nmap <buffer> <C-n> <Cmd>lua MiniStarter.update_current_item('next')<CR>
    " au User MiniStarterOpened nmap <buffer> <C-p> <Cmd>lua MiniStarter.update_current_item('prev')<CR>
  augroup END
]])
  end,
}
