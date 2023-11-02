return {
	"voldikss/vim-floaterm",
	config = function()
		local function opts(desc)
			return { silent = true, desc = "" .. desc }
		end

		-- vim.keymap.set("n", "<leader>t", ":FloatermToggle<CR>", opts("Toggle terminal") )
		vim.keymap.set("n", "<F5>", ":FloatermToggle<CR>", opts("Toggle terminal") )
		vim.keymap.set("t", "<F5>", "<C-\\><C-n>:FloatermToggle<CR>", opts(" Toggle terminal") )
		-- vim.keymap.set("n", "<F6>", ":FloatermNew<CR>", opts("New terminal") )
		-- vim.keymap.set("t", "<F6>", "<C-\\><C-n>:FloatermNew<CR>", opts("New terminal") )
		-- vim.keymap.set("n", "<F7>", ":FloatermKill!<CR>", opts("Kill terminal") )
		-- vim.keymap.set("t", "<F7>", "<C-\\><C-n>:FloatermKill!<CR>", opts("Kill terminal") )
		-- vim.keymap.set("n", "<a-n>", ":FloatermNext<CR>", opts("Next terminal") )
		-- vim.keymap.set("t", "<a-n>", "<C-\\><C-n>:FloatermNext<CR>", opts("Next terminal") )
		-- vim.keymap.set("n", "<a-p>", ":FloatermPrev<CR>", opts("Previous terminal") )
		-- vim.keymap.set("t", "<a-p>", "<C-\\><C-n>:FloatermPrev<CR>", opts("Previous terminal") )

		vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", opts("Switch from terminal to normal mode") )
	end,
}
