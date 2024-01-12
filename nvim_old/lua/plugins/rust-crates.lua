return {
	"saecki/crates.nvim",
  ft = {
    "toml",
  },
	config = function()
		local crates = require("crates")

		crates.setup({
			popup = {
				autofocus = true,
			},
		})

		local function opts(desc)
			return { desc = "Crates: " .. desc, silent = true }
		end

		vim.keymap.set("n", "<leader>ct", crates.toggle, opts("Toggle"))
		vim.keymap.set("n", "<leader>cr", crates.reload, opts("Reload"))

		vim.keymap.set("n", "<leader>cv", crates.show_versions_popup, opts("Show versions"))
		vim.keymap.set("n", "<leader>cf", crates.show_features_popup, opts("Show features"))
		vim.keymap.set("n", "<leader>cd", crates.show_dependencies_popup, opts("Show dependencies"))

		vim.keymap.set("n", "<leader>cu", crates.update_crate, opts("Update crate"))
		vim.keymap.set("v", "<leader>cu", crates.update_crates, opts("Update crates (selected)"))
		vim.keymap.set("n", "<leader>ca", crates.update_all_crates, opts("Update crates (all)"))
		vim.keymap.set("n", "<leader>cU", crates.upgrade_crate, opts("Upgrade crate"))
		vim.keymap.set("v", "<leader>cU", crates.upgrade_crates, opts("Upgrade crates (selected)"))
		vim.keymap.set("n", "<leader>cA", crates.upgrade_all_crates, opts("Upgrade crates (all)"))

		vim.keymap.set("n", "<leader>cH", crates.open_homepage, opts("Open homepage"))
		vim.keymap.set("n", "<leader>cR", crates.open_repository, opts("Open repo"))
		vim.keymap.set("n", "<leader>cD", crates.open_documentation, opts("Open doc"))
		vim.keymap.set("n", "<leader>cC", crates.open_crates_io, opts("Open crates.io"))

    -- Load autocompletion source lazify
		vim.api.nvim_create_autocmd("BufRead", {
			group = vim.api.nvim_create_augroup("CmpSourceCargo", { clear = true }),
			pattern = "Cargo.toml",
			callback = function()
				require('cmp').setup.buffer({ sources = { { name = "crates" } } })
			end,
		})
	end,
}
