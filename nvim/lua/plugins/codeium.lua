return {
  {
    "jcdickinson/http.nvim",
    enabled = os.getenv("USE_AI_TOOLS") == "true",
    event = "VeryLazy",
    build = "cargo build --workspace --release"
  },
  {
    "jcdickinson/codeium.nvim",
    -- event = "VeryLazy",
    -- event = "BufEnter",
    -- enabled = os.getenv("USE_AI_TOOLS") == "true",
    enabled = false,
    dependencies = {
      "jcdickinson/http.nvim",
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    opts = {},
  }
}
