return {
  "echasnovski/mini.starter",
  event = "VimEnter",
  config = function()
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
          "Telescope",
          "Explorer",
          "Plugins",
          "Builtin actions",
        }),
      },
      evaluate_single = true,
      footer = os.date("%A, %m/%d/%Y %I:%M %p"),

      header = table.concat({
        [[  /\ \▔\___  ___/\   /(●)_ __ ___  ]],
        [[ /  \/ / _ \/ _ \ \ / / | '_ ` _ \ ]],
        [[/ /\  /  __/ (_) \ V /| | | | | | |]],
        [[\_\ \/ \___|\___/ \_/ |_|_| |_| |_|]],
        [[───────────────────────────────────]],
      }, "\n"),
      query_updaters = [[abcdefghilmnopqrstuvwxyz0123456789_-,.ABCDEFGHIJKLMNOPQRSTUVWXYZ]],

      -- stylua: ignore
      items = {
        starter.sections.recent_files(9, true, false),
        { action = "Lazy",                                        name = "L: Lazy",        section = "Plugins" },
        { action = "LazyExtra",                                   name = "X: LazyExtras",  section = "Plugins" },
        { action = "Mason",                                       name = "M: Mason",       section = "Plugins" },
        { action = ":lua require('lazyvim.util.lazygit').open()", name = "G: LazyGit",     section = "Plugins" },
        { action = "enew | startinsert",                          name = "N: New Buffer",  section = "Builtin actions" },
        { action = "qall!",                                       name = "Q: Quit Neovim", section = "Builtin actions" },
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
