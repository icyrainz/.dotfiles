return {
    "Bryley/neoai.nvim",
		enabled = os.getenv("USE_AI_TOOLS") == "true",
    dependencies = {
        "MunifTanjim/nui.nvim",
    },
    cmd = {
        "NeoAI",
        "NeoAIOpen",
        "NeoAIClose",
        "NeoAIToggle",
        "NeoAIContext",
        "NeoAIContextOpen",
        "NeoAIContextClose",
        "NeoAIInject",
        "NeoAIInjectCode",
        "NeoAIInjectContext",
        "NeoAIInjectContextCode",
    },
    config = function()
        require("neoai").setup({
            -- Options go here
        })
    end,
}
