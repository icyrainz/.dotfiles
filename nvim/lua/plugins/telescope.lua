return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.1",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local builtin = require("telescope.builtin")
			local utils = require("telescope.utils")

			local function opts(desc)
				return { desc = "telescope: " .. desc }
			end

			vim.keymap.set("n", "<leader>ff", builtin.find_files, opts("Find files"))
			vim.keymap.set(
				"n",
				"<leader>fa",
				"<cmd> Telescope find_files follow=true no_ignore=true hidden=true <CR>",
				opts("Find files (all)")
			)
			vim.keymap.set("n", "<leader>fe", function()
				builtin.live_grep({ cwd = utils.buffer_dir() })
			end, opts("Find files in same dir"))
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, opts("Grep"))
			vim.keymap.set("n", "<leader>fs", builtin.grep_string, opts("Grep String"))
			vim.keymap.set("n", "<leader>fb", builtin.buffers, opts("Buffers"))
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, opts("Help tags"))

			vim.keymap.set("n", "<leader>fr", builtin.resume, opts("Resume"))

			local telescope = require("telescope")
			telescope.setup({
				defaults = {
					file_ignore_patterns = {
						"Session.vim",
					},
				},
			})
		end,
	},
}
