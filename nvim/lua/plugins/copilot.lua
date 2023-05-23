return {
	{
		"zbirenbaum/copilot.lua",
		enabled = os.getenv("USE_AI_TOOLS") == "true",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
    },
	},
	{
		"zbirenbaum/copilot-cmp",
		dependencies = { "zbirenbaum/copilot.lua" },
		enabled = os.getenv("USE_AI_TOOLS") == "true",
    init = function ()
      vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })
    end,
		config = true,
	},
}
