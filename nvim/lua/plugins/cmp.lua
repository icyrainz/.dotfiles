return {
	{
		"L3MON4D3/LuaSnip",
		dependencies = {
			"rafamadriz/friendly-snippets",
		},
		config = function()
			require("luasnip.loaders.from_vscode").lazy_load()
		end,
	},
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-cmdline",
	"saadparwaiz1/cmp_luasnip",
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"L3MON4D3/LuaSnip",
			"VonHeikemen/lsp-zero.nvim",
		},
		config = function()
			require("lsp-zero").extend_cmp()

			local cmp = require("cmp")
			local cmp_action = require("lsp-zero").cmp_action()

			cmp.setup({
				sources = {
					{ name = "copilot" },
					{ name = "nvim_lsp" },
					{ name = "path" },
					{ name = "buffer" },
					{ name = "luasnip", keuword_length = 2 },
				},
				window = {
					documentation = cmp.config.window.bordered(),
				},
				formatting = {
					fields = { "menu", "abbr", "kind" },

					format = function(entry, item)
						local kind_icons = {
							Text = "",
							Method = "󰆧",
							Function = "󰊕",
							Constructor = "",
							Field = "󰇽",
							Variable = "󰂡",
							Class = "󰠱",
							Interface = "",
							Module = "",
							Property = "󰜢",
							Unit = "",
							Value = "󰎠",
							Enum = "",
							Keyword = "󰌋",
							Snippet = "",
							Color = "󰏘",
							File = "󰈙",
							Reference = "",
							Folder = "󰉋",
							EnumMember = "",
							Constant = "󰏿",
							Struct = "",
							Event = "",
							Operator = "󰆕",
							TypeParameter = "󰅲",
						}
						local menu_icon = {
							copilot = "",
							nvim_lsp = "λ",
							path = "🖫",
              buffer = "",
              luasnip = "⋗",
						}
            item.kind = string.format('%s %s', kind_icons[item.kind], item.kind)
						item.menu = menu_icon[entry.source.name]
						return item
					end,
				},
				mapping = {
					["<Tab>"] = cmp_action.luasnip_supertab(),
					["<S-Tab>"] = cmp_action.luasnip_shift_supertab(),
					["<CR>"] = cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Replace,
						select = false,
					}),
				},
			})

			cmp.setup.cmdline("/", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{
						name = "cmdline",
						option = {
							ignore_cmds = { "Man", "!" },
						},
					},
				}),
			})
		end,
	},
}
