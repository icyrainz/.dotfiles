return {
	{
		"mfussenegger/nvim-dap",
		config = function()
			local function opts(desc)
				return { desc = "DAP " .. desc }
			end

			vim.keymap.set("n", "<F8>", function()
				require("dap").terminate()
			end, opts("terminate"))
			vim.keymap.set("n", "<F9>", function()
				require("dap").continue()
			end, opts("continue"))
			vim.keymap.set("n", "<F10>", function()
				require("dap").step_over()
			end, opts("step over"))
			vim.keymap.set("n", "<F11>", function()
				require("dap").step_into()
			end, opts("step into"))
			vim.keymap.set("n", "<F12>", function()
				require("dap").step_out()
			end, opts("step out"))
			vim.keymap.set("n", "<Leader>db", function()
				require("dap").toggle_breakpoint()
			end, opts("toggle breakpoint"))
			vim.keymap.set("n", "<Leader>dB", function()
				require("dap").set_breakpoint()
			end, opts("set breakpoint"))
			vim.keymap.set("n", "<Leader>dm", function()
				require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
			end, opts("Log point"))
			vim.keymap.set("n", "<Leader>dr", function()
				require("dap").repl.open()
			end, opts("open REPL"))
			vim.keymap.set("n", "<Leader>dl", function()
				require("dap").run_last()
			end, opts("run last"))
			vim.keymap.set("n", "<Leader>dc", function()
				require("dap").run_to_cursor()
			end, opts("run last"))
			vim.keymap.set({ "n", "v" }, "<Leader>dh", function()
				require("dap.ui.widgets").hover()
			end, opts("hover"))
			vim.keymap.set({ "n", "v" }, "<Leader>dp", function()
				require("dap.ui.widgets").preview()
			end, opts("preview"))
			vim.keymap.set("n", "<Leader>df", function()
				local widgets = require("dap.ui.widgets")
				widgets.centered_float(widgets.frames)
			end, opts("frames"))
			vim.keymap.set("n", "<Leader>ds", function()
				local widgets = require("dap.ui.widgets")
				widgets.centered_float(widgets.scopes)
			end, opts("scopes"))

			require("nvim-dap-virtual-text").setup()
			require("dapui").setup()

			vim.keymap.set("n", "<Leader>dt", function()
				require("dapui").toggle()
			end, opts("toggle UI"))
			vim.keymap.set("n", "<Leader>dt[", function()
				require("dapui").toggle(1)
			end, opts("toggle UI"))
			vim.keymap.set("n", "<Leader>dt]", function()
				require("dapui").toggle(2)
			end, opts("toggle UI"))

			local dap, dapui = require("dap"), require("dapui")

			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open({
					reset = true,
				})
			end
			--
			-- dap.listeners.before.event_terminated["dapui_config"] = function()
			-- 	dapui.close({})
			-- 	dapui.setup()
			-- end
			--
			-- dap.listeners.before.event_exited["dapui_config"] = function()
			-- 	dapui.close({})
			-- 	dapui.setup()
			-- end
		end,
	},
	"theHamsta/nvim-dap-virtual-text",
	"rcarriga/nvim-dap-ui",
	{
		"jay-babu/mason-nvim-dap.nvim",
		dependencies = {
			"mfussenegger/nvim-dap",
		},
		config = function()
			require("mason-nvim-dap").setup({
				ensure_installed = { "rust", "js", "node2" },
				handlers = {
					function(config)
						require("mason-nvim-dap").default_setup(config)
					end,
					node2 = function(config)
						config.configurations = nil

						require("mason-nvim-dap").default_setup(config)
					end,
				},
			})

			local dap = require("dap")
			dap.adapters["pwa-node"] = dap.adapters.node2
			-- dap.defaults["pwa-node"].external_terminal = {
			-- 	command = "alacritty",
			-- 	args = { "--hold", "--working-directory", vim.fn.getcwd(), "-e" },
			-- }
		end,
	},
}
