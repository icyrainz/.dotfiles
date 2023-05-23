return {
  {
    "jcdickinson/http.nvim",
    enabled = os.getenv("USE_AI_TOOLS") == "true",
    build = "cargo build --workspace --release"
  },
  {
    "jcdickinson/codeium.nvim",
    enabled = os.getenv("USE_AI_TOOLS") == "true",
    dependencies = {
      "jcdickinson/http.nvim",
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      require("codeium").setup({
      })
    end
  }
}
