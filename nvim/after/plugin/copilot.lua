-- vim.g.copilot_no_tab_map = true
--
-- local function opts(desc)
--   return { desc = 'copilot: ' .. desc, silent = true, expr = true }
-- end
--
-- vim.api.nvim_set_keymap("i", "<C-BS>", 'copilot#Accept("<CR>") .. "<Esc>"', opts("Accept suggestion and exit insert mode"))
-- vim.api.nvim_set_keymap("i", "<C-CR>", 'copilot#Accept("<CR>")', opts("Accept suggestion"))
-- vim.api.nvim_set_keymap("i", "<C-q>", 'copilot#Next()', opts("Next suggestion"))
-- vim.api.nvim_set_keymap("i", "<C-a>", 'copilot#Previous()', opts("Previous suggestion"))
-- vim.api.nvim_set_keymap("i", "<C-s>", 'copilot#Suggest()', opts("Suggest"))
-- vim.api.nvim_set_keymap("i", "<C-c>", 'copilot#Dismiss()', opts("Dismiss"))
--
-- vim.api.nvim_set_hl(0, 'CopilotSuggestion', { fg = '#5555a1' })

if os.getenv("NEOVIM_DISABLE_COPILOT") ~= 1 then
	require("copilot").setup({
		suggestion = { enabled = false },
		panel = { enabled = false },
	})

	require("copilot_cmp").setup()
end
