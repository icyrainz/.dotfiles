return {
	{
		"ibhagwan/fzf-lua",
		config = function()
			local actions = require("fzf-lua").actions

			require("fzf-lua").setup({
				"fzf-native",
				grep = {
					file_ignore_patterns = require('utils').file_ignore_patterns,
				},
				winopts = {
					preview = {
						default = "bat",
					},
          hl = {
            normal = "TelescopeResultsNormal",
            border = "TelescopeResultsBorder",
            cursornr = "TelescopeResultsLineNr",
          },
				},
				-- file_ignore_patterns = {
				-- },
				keymap = {
					builtin = {
						["<F1>"] = "toggle-help",
						["<F2>"] = "toggle-fullscreen",
						-- Only valid with the 'builtin' previewer
						["<F3>"] = "toggle-preview-wrap",
						["<F4>"] = "toggle-preview",
						["<F5>"] = "toggle-preview-ccw",
						["<F6>"] = "toggle-preview-cw",
						["<C-d>"] = "preview-page-down",
						["<C-u>"] = "preview-page-up",
						["<S-left>"] = "preview-page-reset",
					},
					fzf = {
						["ctrl-z"] = "abort",
						["ctrl-f"] = "half-page-down",
						["ctrl-b"] = "half-page-up",
						["ctrl-a"] = "beginning-of-line",
						["ctrl-e"] = "end-of-line",
						["alt-a"] = "toggle-all",
						-- Only valid with fzf previewers (bat/cat/git/etc)
						["f3"] = "toggle-preview-wrap",
						["f4"] = "toggle-preview",
						["ctrl-d"] = "preview-page-down",
						["ctrl-u"] = "preview-page-up",
						["ctrl-q"] = "select-all+accept",
					},
				},
				actions = {
					files = {
						["default"] = actions.file_edit_or_qf,
						["ctrl-s"] = actions.file_split,
						["ctrl-v"] = actions.file_vsplit,
						["ctrl-t"] = actions.file_tabedit,
						["alt-q"] = actions.file_sel_to_qf,
						["alt-l"] = actions.file_sel_to_ll,
					},
					buffers = {
						["default"] = actions.buf_edit,
						["ctrl-x"] = actions.buf_split,
						["ctrl-v"] = actions.buf_vsplit,
						["ctrl-t"] = actions.buf_tabedit,
					},
				},
				buffers = {
					keymap = { builtin = { ["<C-d>"] = false } },
					actions = { ["ctrl-x"] = false, ["ctrl-d"] = { actions.buf_del, actions.resume } },
				},
			})
		end,
    keys = {
      { "<leader>fF", "<CMD>FzfLua files<CR>", desc = "[Fzf] files" },
      { "<leader>fW", "<CMD>FzfLua grep_cword<CR>", desc = "[Fzf] grep word" },
      { "<leader>fO", function()
        require("fzf-lua").oldfiles({
          cwd_only = function()
            return vim.api.nvim_command("pwd") ~= vim.env.HOME
          end,
        })
      end, desc = "[Fzf] oldfiles" },
      { "<leader>fG", "<CMD>FzfLua grep_project<CR>", desc = "[Fzf] grep project" },
      { "<leader>fT", "<CMD>FzfLua resume<CR>", desc = "[Fzf] resume" },
    }
	},
}
