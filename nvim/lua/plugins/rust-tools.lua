return {
	"simrat39/rust-tools.nvim",
	ft = { "rust" },
	dependencies = {
		"neovim/nvim-lspconfig",
		"nvim-lua/plenary.nvim",
		"mfussenegger/nvim-dap",
	},
	opts = function()
		local mason_registry = require("mason-registry")
		local codelldb = mason_registry.get_package("codelldb")

		local extension_path = codelldb:get_install_path() .. "/extension/"
		local codelldb_path = extension_path .. "adapter/codelldb"
		local liblldb_path = extension_path .. "lldb/lib/liblldb.dylib"

		return {
			tools = {
				hover_actions = {
					auto_focus = true,
				},
			},
			server = {
				on_attach = function(client, bufnr)
					vim.keymap.set(
						"n",
						"<leader>rr",
						":RustRunnables<CR>",
						{ buffer = bufnr, desc = "Rust: Runnables" }
					)
					vim.keymap.set(
						"n",
						"<leader>rd",
						":RustDebuggables<CR>",
						{ buffer = bufnr, desc = "Rust: Debuggables" }
					)
					vim.keymap.set(
						"n",
						"<leader>ra",
						":RustCodeAction<CR>",
						{ buffer = bufnr, desc = "Rust: Code action" }
					)
					vim.keymap.set(
						"n",
						"<leader>rh",
						":RustHoverActions<CR>",
						{ buffer = bufnr, desc = "Rust: Hover actions" }
					)
					vim.keymap.set(
						"n",
						"<leader>ri",
						":RustEnableInlayHints<CR>",
						{ buffer = bufnr, desc = "Rust: Enable inlay hints" }
					)
					vim.keymap.set(
						"n",
						"<leader>ro",
						":RustDisableInlayHints<CR>",
						{ buffer = bufnr, desc = "Rust: Disable inlay hints" }
					)

					vim.keymap.set("n", "<leader>cb", ":Cbuild<CR>", { buffer = bufnr, desc = "Cargo: Build" })
					vim.keymap.set("n", "<leader>cr", ":Crun<CR>", { buffer = bufnr, desc = "Cargo: Run" })

					vim.keymap.set("n", "<leader>rf", ":RustFmt<CR>", { buffer = bufnr, desc = "Rust: Format" })
				end,
			},
			dap = {
				adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
			},
		}
	end,
}
