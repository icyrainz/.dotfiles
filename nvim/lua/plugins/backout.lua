return {
	"AgusDOLARD/backout.nvim",
	opts = {},
	keys = {
        -- Define your keybinds
		{ "<M-b>", "<cmd>lua require('backout').back()<cr>", mode = { "i" } },
		{ "<M-n>", "<cmd>lua require('backout').out()<cr>", mode = { "i" } },
	},
}
