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
  init = function()
    vim.keymap.set("n", "<leader>nn", "<cmd>NeoAI<CR>", { desc = "NeoAI" })
    -- vim.keymap.set("n", "<leader>no", "<cmd>NeoAIToggle<CR>", { desc = "NeoAI toggle" })
    vim.keymap.set("n", "<leader>nc", "<cmd>NeoAIContext<CR>", { desc = "NeoAI context" })
    vim.keymap.set("n", "<leader>ni", "<cmd>NeoAIInject<CR>", { desc = "NeoAI inject" })
    vim.keymap.set("n", "<leader>nI", "<cmd>NeoAIInjectCode<CR>", { desc = "NeoAI inject code" })
    vim.keymap.set("n", "<leader>nj", "<cmd>NeoAIInjectContext<CR>", { desc = "NeoAI inject context" })
    vim.keymap.set("n", "<leader>nJ", "<cmd>NeoAIInjectContextCode<CR>", { desc = "NeoAI inject context code" })
  end,
  opts = {
    prompts = {
        context_prompt = function(context)
            return "I'm a seasoned software engineer. Skip all the small talk and let's get to the point. "
                .. "Skip all basic instructions. Provide concise with deep technical explanation."
                .. "Provide answers that are relevant to my context. "
                .. "Here is my context:\n\n"
                .. context
        end,
    },
    shortcuts = {
    },
  },
  config = function()
    require("neoai").setup({
    })
  end,
}
