return {
	"echasnovski/mini.nvim",
	config = function()
		require("mini.ai").setup()

		require("mini.basics").setup()

		-- require("mini.animate").setup()

		require("mini.bracketed").setup()

		require("mini.bufremove").setup()

		require("mini.comment").setup()

		require("mini.splitjoin").setup()

		require("mini.surround").setup()

		require("mini.indentscope").setup()

		-- require('mini.jump').setup()

		require("mini.pairs").setup()

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

		require("mini.map").setup()
		vim.keymap.set("n", "<leader>mc", MiniMap.close, { desc = "Close MiniMap" })
		vim.keymap.set("n", "<leader>mf", MiniMap.toggle_focus, { desc = "Toggle MiniMap focus" })
		vim.keymap.set("n", "<leader>mo", MiniMap.open, { desc = "Open MiniMap" })
		vim.keymap.set("n", "<leader>mr", MiniMap.refresh, { desc = "Refresh MiniMap" })
		vim.keymap.set("n", "<leader>ms", MiniMap.toggle_side, { desc = "Toggle MiniMap sidebar" })
		vim.keymap.set("n", "<leader>mt", MiniMap.toggle, { desc = "Toggle MiniMap" })

		-- require('mini.tabline').setup()
		-- require('mini.statusline').setup()

		require("mini.trailspace").setup()

		require("mini.sessions").setup()

		-- Mini starter
		local status, starter = pcall(require, "mini.starter")
		if not status then
			return
		end

		starter.setup({
			content_hooks = {
				starter.gen_hook.adding_bullet(""),
				starter.gen_hook.aligning("center", "center"),
        starter.gen_hook.indexing(
          "section",
          {
            "Git", "Telescope", "Plugins", "Builtin actions",
          }
        ),
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
			query_updaters = [[abcdefghilmoqrstuvwxyz0123456789_-,.ABCDEFGHIJKLMOQRSTUVWXYZ]],
			items = {
        starter.sections.recent_files(5, true, false),
				{ action = "tab G", name = "G: Fugitive", section = "Git" },
				{ action = "Lazy", name = "U: Update Plugins", section = "Plugins" },
				{ action = "enew", name = "N: New Buffer", section = "Builtin actions" },
				{ action = "qall!", name = "Q: Quit Neovim", section = "Builtin actions" },
			},
		})

		vim.cmd([[
  augroup MiniStarterJK
    au!
    au User MiniStarterOpened nmap <buffer> j <Cmd>lua MiniStarter.update_current_item('next')<CR>
    au User MiniStarterOpened nmap <buffer> k <Cmd>lua MiniStarter.update_current_item('prev')<CR>
    au User MiniStarterOpened nmap <buffer> <C-p> <Cmd>Telescope find_files<CR>
    au User MiniStarterOpened nmap <buffer> <C-n> <Cmd>Telescope file_browser<CR>
  augroup END
]])
	end,
}
