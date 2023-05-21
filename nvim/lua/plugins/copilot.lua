return {
  {
    'zbirenbaum/copilot.lua',
  },
  {
    'zbirenbaum/copilot-cmp',
    dependencies = { 'zbirenbaum/copilot.lua' },
    config = function()
      if os.getenv("NEOVIM_DISABLE_COPILOT") ~= 1 then
        require("copilot").setup({
          suggestion = { enabled = false },
          panel = { enabled = false },
        })

        require("copilot_cmp").setup()
      end

      vim.api.nvim_set_hl(0, "CmpItemKindCopilot", {fg ="#6CC644"})
    end,
  },
}
